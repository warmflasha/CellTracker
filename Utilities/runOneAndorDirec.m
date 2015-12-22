function [outdat, nuc, fimg]=runOneAndorDirec(direc,paramfile,nucchan)
tic;

global userParam;
try
    eval(paramfile);
catch
    disp('Error evaluating paramfile');
    return;
end


%get the filename structure
files=readAndorDirectory(direc);

%read nuclear channel
filename = getAndorFileName(files,[],[],[],nucchan);
nuc=imread(filename);
nuc=smoothImage(nuc,userParam.gaussRadius,userParam.gaussSigma);


otherchannums = setdiff(files.w,nucchan);
nImages = length(otherchannums);

for ii=1:nImages
    filename=getAndorFileName(files,[],[],[],otherchannums(ii));
    fimg(:,:,ii)=imread(filename);    
end

nuc = smoothImage(nuc,userParam.gaussRadius,userParam.gaussSigma);

for xx=1:nImages
    fimg(:,:,xx) = smoothImage(fimg(:,:,xx),userParam.gaussRadius,userParam.gaussSigma);
end

if isfield(userParam,'presubNucBackground') && userParam.presubNucBackground
    nuc =presubBackground_self(nuc);
end

if isfield(userParam,'presubSmadBackground') && userParam.presubSmadBackground
    for xx=1:size(fimg,3)
        fimg(:,:,xx)=presubBackground_self(fimg(:,:,xx));
    end
end

[maskC, statsN]=segmentCells2(nuc,fimg);
[~, statsN]=addCellAvr2Stats(maskC,fimg,statsN);
outdat=outputData4AWTracker(statsN,nuc,nImages);

if userParam.verboseSegmentCells
    showImgAndPoints(nuc,outdat);
end
toc;
