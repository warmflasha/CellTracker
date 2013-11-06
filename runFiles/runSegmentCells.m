function runSegmentCells(direc,outfile,nframes,...
    nucstring,smadstring,paramfile,logfile,chnum,backgroundstr,bdirec)
%
%   runSegmentCells(direc,outfile,nframes,nucstring,smadstring,paramfile)
%
% Runs segment cells for all files in a directory
%   direc -- directory containing the images
%   outfile -- name of the .mat where the output will be stored
%   nframes -- number of frames to run (limited by max frames available)
%   nucstring, smadstring -- any string uniquely identifying the relevant files
%               for smads can be a cell array
%   paramfile -- will run eval(paramfile) to load parameters
%   logfile, chnum -- optional arguments to give logfile and chamber number
%                   from culture chip experiment. If available incl in .mat file
%   backgroundstr -- This allows for using a predefined background image,
%   can either be a string analogous to nucstring in which case the program 
%   will expect to find a
%   background image for each time point, or an image in which case it
%   will be used at all time points. backgroundstr should be a cell array
%   containing either the string or image for every channel.
%   NB: background images will be smoothed and processed with imopen, see
%   funtion presubBackground.m
%
% Output: a outfile.mat file with all the data, for defns see end of loop
%   use userParam.verbose* = 1 flags to turn on various diagnostics, which are
%   all saved in imgfiles().errorstr and if verboseSegmentCell = 1 then also
%   printed errorStr to screen

global userParam;

try
    eval(paramfile);
catch
    error('Could not evaluate paramfile command');
end

if ~exist('bdirec','var')
    bdirec=direc;
end

%get the file names
if iscell(smadstring)
    nImages=length(smadstring);
    for ii=1:nImages
        [smadrange{ii}, smadfiles{ii}]=folderFilesFromKeyword(direc,smadstring{ii});
    end
else
    nImages=1;
    [smadrange{1}, smadfiles{1}]=folderFilesFromKeyword(direc,smadstring);
end
[nucrange, nucfiles]=folderFilesFromKeyword(direc,nucstring);
[goodframes]=intersect(nucrange,smadrange{1});

for ii=2:nImages
    goodframes=intersect(goodframes,smadrange{ii});
end

%if reading in background images, get these file names
if exist('backgroundstr','var')
    disp('Using input image for background. Overriding settings in param file');
    userParam.backgndMethod=-1;
    if ischar(backgroundstr{1})
        diffbgimages=1;
        [nucbkgndrange, nucbkgndfiles]=folderFilesFromKeyword(bdirec,backgroundstr{1});
        for ii=2:length(backgroundstr)
        [Smadbkgndrange{ii-1}, Smadbkgndfiles{ii-1}]=folderFilesFromKeyword(bdirec,backgroundstr{ii});
        end
    else
        diffbgimages=0;
    end
end

pictimes=zeros(nframes,1);

%main loop over frames
for ii=1:min(nframes,length(goodframes))
    
    tic;
    
    disp(['frame ' int2str(ii)]);
    % setup string to hold all the error messages for this frame number
    userParam.errorStr = sprintf('frame= %d\n', ii);
    
    ni=find(nucrange==goodframes(ii));
    for xx=1:nImages
        si(xx)=find(smadrange{xx}==goodframes(ii));
    end
    
    %read the image files
    nucfilename=[direc filesep nucfiles(ni).name];
    nuc=imread(nucfilename);
    for xx=1:nImages
        smadfilename{xx}=[direc filesep smadfiles{xx}(si(xx)).name];
        fimg(:,:,xx)=imread(smadfilename{xx});
    end
    if length(size(nuc))==3
        nuc=squeeze(nuc(:,:,1));
    end
    
    
    %if using separate background files,read background files and subtract
    if userParam.backgndMethod==-1 && exist('backgroundstr','var')
        if diffbgimages == 1
            nbgi=find(nucbkgndrange==goodframes(ii));
            nucbkgndfilename=[bdirec filesep nucbkgndfiles(nbgi).name];
            nucbg=imread(nucbkgndfilename);
            for xx=1:length(Smadbkgndrange)
            sbgi=find(Smadbkgndrange{xx}==goodframes(ii));
            Smadbkgndfilename=[bdirec filesep Smadbkgndfiles{xx}(sbgi).name];
            smadbg{xx}=imread(Smadbkgndfilename);
            end
        else
            nucbg=backgroundstr{1};
            smadbg=backgroundstr{2};
        end
        [nuc fimg]=presubBackground(nuc,fimg,nucbg,smadbg);
    end
    
    %if set, use imopen to generate background image and subtract from
    %nuc image
    
    if isfield(userParam,'presubNucBackground') && userParam.presubNucBackground
        nuc =presubBackground_self(nuc);
    end
    
    %get time from file date stamp in hours,
    %record some info about image file.
    if ii==1
        time1=nucfiles(ni).datenum;
    elseif ii > 1
        pictimes(ii)=(nucfiles(ni).datenum-time1)*24;
    end
    imgfiles(ii).nucfile=nucfiles(ni).name;
    imgfiles(ii).time=pictimes(ii);
    imgfiles(ii).size=size(nuc);
    
    %run EDS routines to segment cells, do stats, and get the output
    %matrix
    try
        [maskC statsN]=segmentCells(nuc,fimg);
        
        [tmp statsN]=addCellAvr2Stats(maskC,fimg,statsN);
        outdat=outputData4AWTracker(statsN,nuc,nImages);
    catch
        peaks{ii}=[];
        statsArray{ii}=[];
        continue;
    end
    for xx=1:nImages
        imgfiles(ii).smadfile{xx}=smadfiles{xx}(si(xx)).name;
    end
    % copy over error string, NOTE different naming conventions in structs userParam 
    % vs imgfiles.
    imgfiles(ii).errorstr = userParam.errorStr;
    if userParam.verboseSegmentCells
        display(userParam.errorStr);
    end
    % compress and save the binary mask for nuclei
    imgfiles(ii).compressNucMask = compressBinaryImg([statsN.PixelIdxList], size(nuc) );
    peaks{ii}=outdat;
    
    %This prevents the resulting mat files from becoming too large.
    %If still a problem, could use the compressBinaryImg routine to
    %
    statsN = rmfield(statsN,'VPixelIdxList');
    statsArray{ii}=statsN;
    
    toc;
end

dateSegmentCells = clock;
if exist('logfile') && exist('chnum') && ~isempty(logfile) && ~isempty(chnum)
    feedings=getfeedings(logfile,chnum,nucfiles(1).datenum);
    save(outfile,'peaks','statsArray','imgfiles','userParam','pictimes','dateSegmentCells','feedings');
else
    save(outfile,'peaks','statsArray','imgfiles','userParam','pictimes','dateSegmentCells');
end