function nuc=presubBackground_self(nuc)

global userParam;
nucbgi=imopen(nuc,strel('disk',userParam.backdiskrad));
nuc=imsubtract(nuc,nucbgi);
