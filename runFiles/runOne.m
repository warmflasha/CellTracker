function [outdat, nuc, fimg, maskCyto]=runOne(indir,channames,frame,bIms,nIms,paramfile)

global userParam;

try
    eval(paramfile);
catch
    error('Error evaluating paramfile.');
end

nImages=length(channames)-1;

for ii=1:length(channames)
    [~, ff{ii}]=folderFilesFromKeyword(indir,channames{ii});
end

f1nm=[indir filesep ff{1}(frame).name];
disp(['Nuc marker img:' f1nm]);

nuc=imread(f1nm);
nuc=smoothImage(nuc,userParam.gaussRadius,userParam.gaussSigma);
nuc=imsubtract(nuc,bIms{1});
nuc=immultiply(im2double(nuc),nIms{1});
nuc=uint16(65536*nuc);

si=size(nuc);
fimg=zeros(si(1),si(2),nImages);
for jj=2:(nImages+1)
    f1nm=[indir filesep ff{jj}(frame).name];
    disp(['marker img:' f1nm]);
    
    fimgnow=imread(f1nm);
    fimgnow = smoothImage(fimgnow,userParam.gaussRadius,userParam.gaussSigma);
    fimgnow=imsubtract(fimgnow,bIms{jj});
    fimgnow=immultiply(im2double(fimgnow),nIms{jj});
    fimg(:,:,jj-1)=uint16(65536*fimgnow);
    %fimg(:,:,jj-1)=presubBackground_self(fimgnow);
end

%nuc=presubBackground_self(nuc);

[maskC statsN]=segmentCells2(nuc,fimg);
[maskCyto, statsN]=addCellAvr2Stats(maskC,fimg,statsN);

if userParam.verboseSegmentCells
    display(userParam.errorStr);
end

if ~isempty(statsN)
    outdat=outputData4AWTracker(statsN,nuc,nImages);
end


