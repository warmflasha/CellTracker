function mm=mkNucMask(statsN,imsize)
mm=zeros(imsize);

for ii=1:length(statsN)
    mm(statsN(ii).PixelIdxList)=1;
end