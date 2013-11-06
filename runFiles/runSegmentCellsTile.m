function runSegmentCellsTile(direc,outfile,dims,...
    nucstring,smadstring,paramfile,ac,backgroundstr)
%function runSegmentCells(direc,outfile,nframes,...
%   nucstring,smadstring,paramfile)
%--------------------------------------------------------
%Function to call to run the tracker
%direc -- directory containing the images
%outfile -- name of the .mat where the output will be stored
%nframes -- number of frames to run
%nucstring, smadstring -- if sequential mode, this the prefix to which
%the file number is auserParamended giving the filename. if not sequential, this
%is any string uniquely contained in the files
%paramfile -- will run eval(paramfile) to load parameters
%logfile, chnum -- optional arguments to give logfile and chamber number
%                   from culture chip experiment. if supplied will include
%                   feedings structure in output .mat file


global userParam;

try
    eval(paramfile);
catch
    error('Could not evaluate paramfile command');
end

nframes =dims(1)*dims(2);

%get the file names
if iscell(smadstring)
    nImages=length(smadstring);
    for ii=1:nImages
        [smadrange{ii} smadfiles{ii}]=folderFilesFromKeyWord(direc,smadstring{ii});
    end
else
    nImages=1;
    [smadrange{1} smadfiles{1}]=folderFilesFromKeyword(direc,smadstring);
end
[nucrange nucfiles]=folderFilesFromKeyword(direc,nucstring);
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
        [nucbkgndrange nucbkgndfiles]=folderFilesFromKeyword(direc,backgroundstr{1});
        [Smadbkgndrange Smadbkgndfiles]=folderFilesFromKeyword(direc,backgroundstr{2});
    else
        diffbgimages=0;
    end
end

%run the alignment rountine, get the coordinates of each image
if ~exist('ac','var')
    disp('Begining panel alignment...');
    ac=alignManyPanels2(nucstring,1,4,dims,85:150);
    save(outfile,'ac');
    disp('Finished panel alignment');
else
    disp('Using inputted alignment...');
end
pictimes=zeros(nframes,1);

%main loop over frames
for ii=1:min(nframes,length(goodframes))
    
    tic;
    
    disp(['frame ' int2str(ii)]);
    
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
    if userParam.backgndMethod==-1
        if diffbgimages == 1
            nbgi=find(nucbkgndrange==goodframes(ii));
            nucbkgndfilename=[direc filesep nucbkgndfiles(nbgi).name];
            sbgi=find(Smadbkgndrange==goodframes(ii));
            Smadbkgndfilename=[direc filesep Smadbkgndfiles(sbgi).name];
            nucbg=imread(nucbkgndfilename);
            smadbg=imread(Smadbkgndfilename);
        else
            nucbg=backgroundstr{1};
            smadbg=backgroundstr{2};
        end
        [nuc fimg]=presubBackground(nuc,fimg,nucbg,smadbg);
    end
    
    %if set, use imopen to generate background image and subtract from
    %nuc image
    
    if userParam.presubNucBackground
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
        goon=1;
    catch
        goon=0;
    end
    if goon==1 && ~isempty(statsN)
        [tmp statsN]=addCellAvr2Stats(maskC,fimg,statsN);
        outdat=outputData4AWTracker(statsN,nuc,nImages);
        indsrem = outdat(:,1) < ac(ii).wside(1) | outdat(:,2) < ac(ii).wabove(1);
        outdat(indsrem,:)=[];
        
        %add the absolute image coords to the data:
        outdat(:,1)=outdat(:,1)+ac(ii).absinds(2);
        outdat(:,2)=outdat(:,2)+ac(ii).absinds(1);
        
        %This prevents the resulting mat files from becoming too large.
        %If still a problem, could use the compressBinaryImg routine to
        %
        statsN = rmfield(statsN,'VPixelIdxList');
    else
        outdat=[];
    end
    for xx=1:nImages
        imgfiles(ii).smadfile{xx}=smadfiles{xx}(si(xx)).name;
    end
    peaks{ii}=outdat;
    
    
    statsArray{ii}=statsN;
    
    toc;
end

dateSegmentCells = clock;

save(outfile,'peaks','statsArray','imgfiles','userParam','pictimes','dateSegmentCells','-append');
