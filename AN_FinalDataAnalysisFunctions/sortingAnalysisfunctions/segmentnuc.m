function [nmask,nuc_p] =  segmentnuc(nucmoviefile,mag,cellIntensity)

cellSize = 2500*(mag/40)^2;
nreader = bfGetReader(nucmoviefile);
nt = nreader.getSizeT;
%cellArea = sqrt(cellSize/pi);

for ii = 1:nt
    disp(['Segmenting image ' int2str(ii)]);
    iplane = nreader.getIndex(0,0,ii-1)+1;
    nuc = bfGetPlane(nreader,iplane);        
    if ii == 1
        imsize = size(nuc);
        nmask = false(imsize(1),imsize(2),nt);       
        nuc_p = uint16(zeros(imsize(1),imsize(2),nt));      
    end        
    [nmask(:,:,ii),~]=simpleSegmentation(nuc,cellSize,cellIntensity,1);      
    [nuc_p(:,:,ii)] = simplebg([],nmask(:,:,ii), nuc);
     % figure, imshow(nmask(:,:,ii)); figure, imshow(nuc_p(:,:,ii),[]);

end