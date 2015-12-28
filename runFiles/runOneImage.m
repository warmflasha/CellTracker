function [outdat, nuc, fimg]=runOneImage(nuc,fimg,paramfile)
% [outdat, nuc, fimg]=runOneImage(nuc,fimg,paramfile)
% ----------------------------------------------------
% run segmentation on one image, already loaded into matlab
% Inputs: 
%   -nuc - segmentation image
%   -fimg - stack of images to quantify relative to segmentation image
%   -paramfile - parameter file to use
% Outputs:
%   -outdat - output of segmentation data in the usual format, one row per
%   cell
%   -nuc - nuclear (segmentation) image, postprocessing
%   -fimg - stack of other images, postprocessing
%

tic;
global userParam;

try
    eval(paramfile);
catch
    error('cannot evalulate parameter file');
end

nImages = size(fimg,3);

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