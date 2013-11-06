function [outdat, nuc, fimg, maskCyto]=runOneFluff(indir,channames,sample,position,frame,paramfile)

global userParam;

try
    eval(paramfile);
catch err
    error('Error evaluating paramfile.');
end

nImages=length(channames)-1;

%f1nm=dir([indir filesep '*' 'Sample' int2str(sample) '_' channames{1} '*' 's' int2str(position)...
%    '_t' int2str(frame) '.TIF']);
f1nm=dir([indir filesep '*' channames{1} '*' 's' int2str(position)...
    '_t' int2str(frame) '.TIF']);

f1nm=[indir filesep f1nm(1).name];
disp(['Nuc marker img:' f1nm]);
nuc=imread(f1nm);
si=size(nuc);
fimg=zeros(si(1),si(2),nImages);
for jj=2:(nImages+1)
    %f1nm=dir([indir filesep '*' 'Sample' int2str(sample) '_' channames{2} '*' 's' int2str(position)...
     %   '_t' int2str(frame) '.TIF']);    f1nm=[indir filesep f1nm(1).name];
    
        f1nm=dir([indir filesep '*' channames{jj} '*' 's' int2str(position)...
        '_t' int2str(frame) '.TIF']);    f1nm=[indir filesep f1nm(1).name];
    disp(['marker img:' f1nm]);
    
    fimgnow=imread(f1nm);
    fimg(:,:,jj-1)=presubBackground_self(fimgnow);
end

nuc=presubBackground_self(nuc);

[maskC, statsN]=segmentCells(nuc,fimg);
[maskCyto, statsN]=addCellAvr2Stats(maskC,fimg,statsN);

if userParam.verboseSegmentCells
    display(userParam.errorStr);
end

if ~isempty(statsN)
    outdat=outputData4AWTracker(statsN,nuc,nImages);
end


