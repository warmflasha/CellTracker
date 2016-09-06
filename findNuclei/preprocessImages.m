function [nuc, fimg] = preprocessImages(nuc,fimg)
%applying smoothing and background subtraction to the images

global userParam;

nuc = smoothImage(nuc,userParam.gaussRadius,userParam.gaussSigma);

if exist('fimg','var');
    nImages = size(fimg,3);
    
    for xx=1:nImages
        fimg(:,:,xx) = smoothImage(fimg(:,:,xx),userParam.gaussRadius,userParam.gaussSigma);
    end
end
if isfield(userParam,'presubNucBackground') && userParam.presubNucBackground
    nuc =presubBackground_self(nuc);
end

if exist('fimg','var')
    if isfield(userParam,'presubSmadBackground') && userParam.presubSmadBackground
        for xx=1:nImages
            fimg(:,:,xx)=presubBackground_self(fimg(:,:,xx));
        end
    end
end