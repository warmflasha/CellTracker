function [ilbl,statstmp1,nt]=getinitmasktotrack(direc1,pos,chan,init,arealow,areahi,toshow)
% returns the labeled mask for the first or other (init) time point in the time-series
% this mask will be used to assign the cells to tracks in all the
% consecutive time points
ff1 = readAndorDirectory(direc1);%
nucmoviefile = getAndorFileName(ff1,ff1.p(pos),2,0,chan); %todo: fix hard coding of the third argument
nreader = bfGetReader(nucmoviefile);
nt = nreader.getSizeT;
celltype1 = zeros(1024,1024,nt) ; % TODO: do not hardcode the size
 jj=pos;
    % get the mask
    ii = init; %
    iplane = nreader.getIndex(0,0,ii-1)+1;
    nuc(:,:,ii) = bfGetPlane(nreader,iplane);
    tmp1 = im2bw(nuc(:,:,ii),graythresh(nuc(:,:,ii))); %graythresh(nuc(:,:,ii))
    tmp2 = imopen(tmp1,strel('disk',1));
    % imshowpair(tmp2,tmp1);
    % figure,imshowpair(nuc(:,:,ii),tmp2);
    % clean the thresholded images and make labeled masks
    ti = init;% initial time point
    statstmp = regionprops(tmp2,'Area','Centroid','PixelIdxList');
    A = cat(1,statstmp.Area);
    % get rid of non-cells
    [badindxlow,~] = find(A<arealow);
    [badindxhigh,~] = find(A>areahi);
    torm = cat(1,badindxlow,badindxhigh);
    % make those pixels black in the image
    pixels = cat(1,statstmp(torm).PixelIdxList);
    I = tmp2;
    I(pixels) = false; % this image does not have junk, only cells
    I = imfill(I,'holes');    
    statstmp1 = regionprops(I,'Centroid','PixelIdxList','A');
    %==== check cells that were left in the mask
%     A = cat(1,statstmp1.Area);
%     xy = cat(1,statstmp1.Centroid);
%     figure(3),imshow(I); hold on
%     plot(xy(:,1),xy(:,2),'pr');hold on
%     text(xy(:,1)+5,xy(:,2)+5,num2str(A),'Color','m');hold on
    %====
    %       opim = imopen(I,strel('disk',1));
    %       figure,imshow(opim,[]);
    %      dilmask = imfill(dilim,'holes');
    %I - mask of the cells at given tp
       ilbl = zeros(size(I));
    for ii=1:size(statstmp1,1)
        ilbl(statstmp1(ii).PixelIdxList) = ii;
    end   
    if toshow == 1
figure,imshow(nuc(:,:,init),[]);
figure, imshow(ilbl,[]);
    end
end