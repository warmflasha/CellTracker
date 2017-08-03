function [nmask,nuc_p, I2_bgsubtract] =  getrawimageseq_bgsub(nucmoviefile,mag,cellIntensity)

cellSize = 2500*(mag/40)^2;
nreader = bfGetReader(nucmoviefile);
nt = nreader.getSizeT;

for ii = 1:nt
    disp(['Segmenting image ' int2str(ii)]);
    iplane = nreader.getIndex(0,0,ii-1)+1;
    nuc = bfGetPlane(nreader,iplane);
    
    if ii == 1
        imsize = size(nuc);
        nmask = false(imsize(1),imsize(2),nt);
        nuc_p = uint16(zeros(imsize(1),imsize(2),nt));
    end    
    
    [nmask(:,:,ii), nuc_p(:,:,ii)]=simpleSegmentation(nuc,cellSize,cellIntensity,false);%false
    [I2_bgsubtract(:,:,ii)] = simplebg([],nmask(:,:,ii),nuc_p(:,:,ii));

end