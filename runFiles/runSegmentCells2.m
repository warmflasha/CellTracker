function runSegmentCells2(direc,outfile,nframes,...
    nucstring,smadstring,filterstring,paramfile,backgroundstr)
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

if ~exist('filterstring','var')
    filterstring = [];
end

%get the file names
if iscell(smadstring)
    nImages=length(smadstring);
    for ii=1:nImages
        [smadrange{ii}, smadfiles{ii}]=folderFilesFromKeyword(direc,smadstring{ii},filterstring);
    end
else
    nImages=1;
    [smadrange{1}, smadfiles{1}]=folderFilesFromKeyword(direc,smadstring,filterstring);
end
[nucrange, nucfiles]=folderFilesFromKeyword(direc,nucstring,filterstring);
[goodframes]=intersect(nucrange,smadrange{1});

for ii=2:nImages
    goodframes=intersect(goodframes,smadrange{ii});
end

%if reading in background images, get these file names
if exist('backgroundstr','var')
    if ischar(backgroundstr{1})
        diffbgimages=1;
        [nucbkgndrange, nucbkgndfiles]=folderFilesFromKeyword(bdirec,backgroundstr{1});
        for ii=2:length(backgroundstr)
            [Smadbkgndrange{ii-1}, Smadbkgndfiles{ii-1}]=folderFilesFromKeyword(bdirec,backgroundstr{ii});
        end
    else
        diffbgimages=0;
        nucbg = smoothImage(backgroundstr{1},userParam.backgroundSmoothRad,userParam.backgroundSmoothSig);
        nucbg = imopen(nucbg,strel('disk',userParam.backgroundOpenRad));
        smadbg = smoothImage(backgroundstr{2},userParam.backgroundSmoothRad,userParam.backgroundSmoothSig);
        smadbg = imopen(smadbg,strel('disk',userParam.backgroundOpenRad));
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
    
    %read the image files, apply gaussian smoothing
    nucfilename=[direc filesep nucfiles(ni).name];
    nuc=imread(nucfilename);
    nuc=smoothImage(nuc,userParam.gaussRadius,userParam.gaussSigma);
    
    for xx=1:nImages
        smadfilename{xx}=[direc filesep smadfiles{xx}(si(xx)).name];
        fimg(:,:,xx)=smoothImage(imread(smadfilename{xx}),userParam.gaussRadius,userParam.gaussSigma);
    end
    
    
    %if using separate background files,read background files and subtract
    if exist('backgroundstr','var')
        if diffbgimages == 1
            nbgi=find(nucbkgndrange==goodframes(ii));
            nucbkgndfilename=[bdirec filesep nucbkgndfiles(nbgi).name];
            nucbg=imread(nucbkgndfilename);
            nucbg = smoothImage(nucbg,userParam.backgroundSmoothRad,userParam.backgroundSmoothSig);
            nucbg = imopen(nucbg,strel('disk',userParam.backgroundOpenRad));
            for xx=1:length(Smadbkgndrange)
                sbgi=find(Smadbkgndrange{xx}==goodframes(ii));
                Smadbkgndfilename=[bdirec filesep Smadbkgndfiles{xx}(sbgi).name];
                smadbg{xx}=imread(Smadbkgndfilename);
                smadbg{xx} = smoothImage(smadbg{xx},userParam.backgroundSmoothRad,userParam.backgroundSmoothSig);
                smadbg{xx} = imopen(smadbg{xx},strel('disk',userParam.backgroundOpenRad));
            end
            nuc=imsubtract(nuc,nucbg);
            for xx=1:size(fimg,3)
                fimg(:,:,xx)=imsubtract(fimg,smadbg{xx});
            end
            
        end
    end
    if isfield(userParam,'presubNucBackground') && userParam.presubNucBackground
        nuc =presubBackground_self(nuc);
    end
    
    if isfield(userParam,'presubSmadBackground') && userParam.presubSmadBackground
        for xx=1:size(fimg,3)
            fimg(:,:,xx)=presubBackground_self(fimg(:,:,xx));
        end
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
    
    %run routines to segment cells, do stats, and get the output matrix
    try 
        [maskC, statsN]=segmentCells2(nuc,fimg);
        [~, statsN]=addCellAvr2Stats(maskC,fimg,statsN);
        outdat=outputData4AWTracker(statsN,nuc,nImages);
    catch err
        disp(['Error with image ' int2str(ii) ' continuing...']);
        
        peaks{ii}=[];
        statsArray{ii}=[];
        rethrow(err);
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
    statsN = rmfield(statsN,'VPixelIdxList');
    statsArray{ii}=statsN;
    
    toc;
end

dateSegmentCells = clock;
save(outfile,'peaks','statsArray','imgfiles','userParam','pictimes','dateSegmentCells');