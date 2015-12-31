function [outdat, nuc, fimg]=runOneAndor(ff,paramfile,pos,time,chan)
% [outdat, nuc, fimg]=runOneAndor(ff,paramfile,pos,time,chan)
% ----------------------------------------------------------------------
% run segmentation of one image from an andor directory
% Inputs: 
%   -ff: andor file structure, produce by readAndorDirectory.m
%   -paramfile: parameter file to use
%   -pos position number (starts from 0)
%   -timepoint (starts from 0)
%   -chan: list of channels to use, first is channel to segment, others are
%           to quantify
% Outputs:
%   -outdat - output of segmentation data in the usual format, one row per
%   cell
%   -nuc - nuclear (segmentation) image, postprocessing
%   -fimg - stack of other images, postprocessing
%
% Note: if the data is a zstack, will take a max-intensity. assumes all files are separate.

tic;
global userParam;

try
    eval(paramfile);
catch
    error('cannot evalulate parameter file');
end

if ~isempty(chan)
    nuc=andorMaxIntensity(ff,pos,time,chan(1));
    nImages = length(chan) - 1;
else
    nuc=andorMaxIntensity(ff,pos,time,[]);
    nImages = 1;
end

if isempty(chan) || length(chan) == 1
    fimg = nuc;
else
    for xx=2:length(chan)
        fimg(:,:,xx-1)=andorMaxIntensity(ff,pos,time,chan(xx));
    end
end


nuc = smoothImage(nuc,userParam.gaussRadius,userParam.gaussSigma);

for xx=1:size(fimg,3)
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