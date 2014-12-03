function [nuc, fimg]=presubBackground(nuc,fimg,nucbg,smadbg)

global userParam;

gfilt=fspecial('gaussian',6*userParam.gaussFilterRadius,userParam.gaussFilterRadius);

nucbgi=imfilter(nucbg,gfilt);
nucbgi=imopen(nucbgi,strel('disk',userParam.backdiskrad));
nuc=imsubtract(nuc,nucbgi);

for ii=1:length(smadbg)
Smadbgi=imfilter(smadbg{ii},gfilt);
Smadbgi=imopen(Smadbgi,strel('disk',userParam.backdiskrad));
fimg(:,:,ii)=fimg(:,:,ii)-Smadbgi;
end