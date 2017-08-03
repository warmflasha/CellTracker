function [datacell,Lnuc] = nuconlyIlastik2data_2Dsegm(mask1,direc1,tp,readers)
% mask1 - mask for nuc channel
% img_nuc - processed image, mask applied to this

% the nuc masks come already filtered and preprocessed
clear Lnuc
clear allchanels

Lnuc = mask1; % 
%if no nuclei, exit
if sum(sum(sum(Lnuc))) == 0
    datacell = [];
    return;
end
% now need to get the raw images in the non-nuclearmarker channel (other
% Fluor chanels, not cyto though
ff = readAndorDirectoryANmod(direc1);
selectZ = 1;
allchanels=cell(1,(size(ff.w,2))) ;
for xx = 1:size(ff.w,2)
planenuc = readers(xx).chanels.getIndex(0,0, tp - 1) + 1;
allchanels{xx} = bfGetPlane(readers(xx).chanels,planenuc);
end
% for jj=1:(size(ff.w,2))   %    
%     [imgsnuc_reader]   =  getrawimgfilesselectZ(direc1,1,(ii-1),[],jj);
%     k = tp;% current time point
%     for m = 1:size(imgsnuc_reader,2) %
%         planenuc = imgsnuc_reader{m}.getIndex(0,0, k - 1) + 1;
%         inuc(:,:,m) = bfGetPlane(imgsnuc_reader{m},planenuc);
%     end
%     % here need the adjusment if these are more than one slices
%     allchanels{jj} = inuc;    
% end
I2proc = zeros(1024,1024,size(ff.w,2));
for ll=1:size(ff.w,2)
    I2proc(:,:,ll) = simplebg([],Lnuc,allchanels{ll}); % here I2proc contains the bg-subtracted images for the good(or only) zplane for all existing chanels
end
%figure, imshowpair(I2proc(:,:,1),Lnuc,'ColorChannels','red-cyan');
% get the stats form each channel using the Lnuc mask and put into the
% datcell matrix

statsnuc = regionprops(imerode(Lnuc,strel('disk',1)),I2proc(:,:,1),'Area','Centroid','PixelIdxList','MeanIntensity');% stas for the nuclear marker
%statsnuc = regionprops(Lnuc,I2proc(:,:,1),'Area','Centroid','PixelIdxList','MeanIntensity');% stas for the nuclear marker

if size(Lnuc,3) ==1
    xyz = round([statsnuc.Centroid]);
xx =  xyz(1:2:end)';
xyzall = zeros(size(xx,1),3); % initialize the atrix for the data once the number of rows is known (ftom size of xx)
yy =  xyz(2:2:end)';
zz =  selectZ*ones(size(xx,1),1);
xyzall = cat(2,xx,yy,zz);
else 
xyz = round([statsnuc.Centroid]);
xx =  xyz(1:3:end)';
xyzall = zeros(size(xx,1),3); % initialize the matrix for the data once the number of rows is known (ftom size of xx)
yy =  xyz(2:3:end)';
zz =  xyz(3:3:end)';
xyzall = cat(2,xx,yy,zz);
end

nuc_avr  = [statsnuc.MeanIntensity]';%
nuc_area  = [statsnuc.Area]';%
datacell = zeros(size(xyzall,1),5+size(ff.w,2)-1);
datacell(:,1:5)=[xyzall(:,1) xyzall(:,2) xyzall(:,3) nuc_area nuc_avr ];%
for k=2:size(ff.w,2) %   (populate the data for the rest of the chanels (so start the loop from 2)
statsother= regionprops(imerode(Lnuc,strel('disk',1)),I2proc(:,:,k),'Area','Centroid','PixelIdxList','MeanIntensity');
%statsother= regionprops(Lnuc,I2proc(:,:,k),'Area','Centroid','PixelIdxList','MeanIntensity');

datacell(:,5+k-1) = [statsother.MeanIntensity]';
end

end