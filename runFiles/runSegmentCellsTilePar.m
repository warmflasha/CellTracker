function runSegmentCellsTilePar(direc,outfile,dims,...
    nucstring,smadstring,paramfile,ac)
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
%                   from culture chip experiment. if suuserParamlied will include
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
time1=nucfiles(1).datenum;


for ii=2:nImages
    goodframes=intersect(goodframes,smadrange{ii});
end

%run the alignment rountine, get the coordinates of each image
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
parfor ii=1:min(nframes,length(goodframes))
    
    tic;
    
    %read the image files
    nucfilename=[direc filesep nucfiles(ii).name];
    nuc=imread(nucfilename);
    siz=size(nuc);
    fimg=zeros(siz(1),siz(2),nImages);
    for xx=1:nImages
        smadfilename=[direc filesep smadfiles{xx}(ii).name];
        fimg(:,:,xx)=imread(smadfilename);
    end
    
    if length(size(nuc))==3
        nuc=squeeze(nuc(:,:,1));
    end
    
    %if set, use imopen to generate background image and subtract from
    %nuc image
    
    if userParam.presubNucBackground
        nuc =presubBackground_self(nuc);
    end
    
    
    
    %get time from file date stamp in hours,
    %record some info about image file.
    if ii==1
        pictimes(ii)=time1;
    elseif ii > 1
        pictimes(ii)=(nucfiles(ii).datenum-time1)*24;
    end
    
    imgfiles(ii).nucfile=nucfiles(ii).name;
    imgfiles(ii).time=pictimes(ii);
    imgfiles(ii).size=size(nuc);
    
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
        imgfiles(ii).smadfile{xx}=smadfiles{xx}(ii).name;
    end
    peaks{ii}=outdat;
    statsArray{ii}=statsN;
    toc;
    disp(['Image ' int2str(ii) ' done.']);
end

dateSegmentCells = clock;

save(outfile,'peaks','statsArray','imgfiles','userParam','pictimes','dateSegmentCells','ac');
