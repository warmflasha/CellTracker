%% code to use watershead marker-based segmentation to separate the nucleus from cytoplasm
function [Lnuc] = Watershedsegm(I,se)
% se = 8 wprks best for the 60X data on signaling
% I2 = imread('SingleCellSignalingAN_t0000_f0019_z0003_w0001.tif');% gfp channel (gfp-smad4 cells)
% I = imread('SingleCellSignalingAN_t0000_f0019_z0003_w0000.tif');% nuc chan
nuc = I;
% nuc_o = nuc;
% preprocess
global userParam;
userParam.gaussRadius = 10;
userParam.gaussSigma = 3;
userParam.small_rad = 3;
userParam.presubNucBackground = 1;
userParam.backdiskrad = 300;

nuc = imopen(nuc,strel('disk',userParam.small_rad)); % remove small bright stuff
nuc = smoothImage(nuc,userParam.gaussRadius,userParam.gaussSigma); %smooth
nuc =presubBackground_self(nuc);
%  Normalize image
diskrad = 100;
low_thresh = 500;

nuc(nuc < low_thresh)=0;
norm = imdilate(nuc,strel('disk',diskrad));
normed_img = im2double(nuc)./im2double(norm);
normed_img(isnan(normed_img))=0;



% threshold and find objects
thresh = 0.04; arealo = 2000; %2000 have this as a parameter in the paramFile

nthresh = normed_img > thresh;

cc =bwconncomp(nthresh);

stats = regionprops(cc,'Area','Centroid');

 badinds = [stats.Area] < arealo; 
 stats(badinds) = [];

xy = [stats.Centroid];
xx=xy(1:2:end);
yy=xy(2:2:end);

figure; imshow(nuc,[]); hold on;
plot(xx,yy,'r*');

 %-------AN
% create the image to input into the watershed segmentation process based
% on the segmentation done above

 Inew = zeros(1024,1024);
 for k=1:length(xx)
 Inew(int32(yy(k)),int32(xx(k))) = 1;
 end
 %figure,imshow(Inew);
 se = strel('disk',se);
 Inew = imdilate(Inew,se);
 %imshow(Inew);
 
%------------------------------------------
 fgm = imregionalmax(Inew);%
 %figure,imshow(fgm); title('foreground');
  
h = fspecial('sobel');
Ix  = imfilter(double(normed_img),h,'replicate'); % f3 if the other algothithm is used
Iy  = imfilter(double(normed_img),h','replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);% this is the image where the dark regions are objects to be segmented (?) doublecheck
%figure, imshow(gradmag);

%now marking the background objects( in the normed_img the dark pixels belong to the background)
%bw = im2bw(normed_img, graythresh(normed_img));

%-----------
D = bwdist(Inew);%bw1

%imshow(D);
DL = watershed(D);
bgm =  DL == 0; %watershed ridge lines (background markers, bgm)
%calculate the watershed transform of the segmentation function
%figure,imshow(bgm);
gradmag2 = imimposemin(gradmag,bgm|fgm);     % modify the image so that it only has ...
...regional minima at desired locations(here the reg. min need to occur only ...
...at foreground and background locations
L = watershed(gradmag2); % final watershed segmentation
%L == 0; % this is where object boundaries are located
% Lrgb = label2rgb(L, 'jet', 'k', 'shuffle');
%figure,imshow(I,[]);hold on
%h = imshow(Lrgb);
%h.AlphaData = 0.3;  % overlap the segmentation with the original image using transparency option of the image object 

Lnuc = L >1;
%cc =bwconncomp(Lnuc);

%stats = regionprops(cc,I,'Area','Centroid','MeanIntensity');
% imshow(I,[]); hold on
% aa = [stats.Centroid];
% xx = aa(1:2:end);
% yy = aa(2:2:end);
% zz = [stats.MeanIntensity];
% 
% plot(xx,yy,'r*');

imshow(Lnuc); 

end


