
function [nmask, cmask, nuc_p, I2_bgsubtract] =  simpleSegmentationLoop(nucmoviefile,fmoviefile,mag,cellIntensity,cellIntensity1)

cellSize = 2500*(mag/40)^2;

nreader = bfGetReader(nucmoviefile);
nt = nreader.getSizeT;

freader = bfGetReader(fmoviefile);
nt = min(nt,freader.getSizeT);

for ii = 1:nt
    disp(['Segmenting image ' int2str(ii)]);
    iplane = nreader.getIndex(0,0,ii-1)+1;
    nuc = bfGetPlane(nreader,iplane);
    
    iplane = freader.getIndex(0,0,ii-1)+1;
    fimg = bfGetPlane(freader,iplane);
    
    if ii == 1
        imsize = size(nuc);
        nmask = false(imsize(1),imsize(2),nt);
        cmask = false(imsize(1),imsize(2),nt);
        nuc_p = uint16(zeros(imsize(1),imsize(2),nt));
        fimg_p = uint16(zeros(imsize(1),imsize(2),nt));
    end    
    

    [nmask(:,:,ii), nuc_p(:,:,ii)]=simpleSegmentation(nuc,cellSize,cellIntensity,false);%false
    [cmask(:,:,ii), fimg_p(:,:,ii)]=simpleSegmentation(fimg,1.5*cellSize,cellIntensity1,false);
    [I2_bgsubtract(:,:,ii)] = simplebg(cmask(:,:,ii),nmask(:,:,ii),fimg);
     I2_bgsubtract(:,:,ii) = fimg;%%%test

end