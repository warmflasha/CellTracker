%% code to use watershead marker-based segmentation to separate the nucleus from cytoplasm
function [L,stats] = Watershedsegm(I)

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
thresh = 0.04; arealo = 1000;

nthresh = normed_img > thresh;

cc =bwconncomp(nthresh);

stats = regionprops(cc,'Area','Centroid','FilledImage');

 badinds = [stats.Area] < arealo; 
 stats(badinds) = [];

xy = [stats.Centroid];
xx=xy(1:2:end);
yy=xy(2:2:end);

figure; imshow(nuc,[]); hold on;
plot(xx,yy,'r*');

 %-------AN

%----------stupid way to do the foreground markers, after gradmag is
%calculated, proceed the same way from line 87
% f = imopen(nuc,strel('disk',11));
% bw1 = im2bw(f,graythresh(f));
% figure,imshow(bw1);
% fgm = imregionalmax(bw1);
% figure,imshow(fgm);
% 
% h = fspecial('sobel');
% Ix  = imfilter(double(bw1),h,'replicate'); %NEED to use nuc channel here
% Iy  = imfilter(double(bw1),h','replicate');
% gradmag = sqrt(Ix.^2 + Iy.^2);

%------------------
 %f = imopen(nuc,strel('disk',20)); % here, instead of nuc, need to use the image, obtained after segmentation
 
%  se = strel('disk',20);
%  preim = imopen(nthresh,se); % remove the small intense dots from the image, before watershed segmentation
 
 f = imerode(nuc,strel('disk',20));
 f1 = imreconstruct(f,nuc);
 f2 = imdilate(f1,strel('disk',20));
 f3 = imreconstruct(imcomplement(f2), imcomplement(f1));
 f3 = imcomplement(f3);
 
% imshow(f,[]);
 
 fgm = imregionalmax(f3);% marking the foreground objects(fgm)
  
 figure,imshow(fgm);

h = fspecial('sobel');
Ix  = imfilter(double(f3),h,'replicate'); %NEED to use nuc channel here
Iy  = imfilter(double(f3),h','replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);% this is the image where the dark regions are objects to be segmented (?) doublecheck
figure, imshow(gradmag);

%now marking the background objects( in the normed_img the dark pixels belong to the background)
%bw = im2bw(normed_img, graythresh(normed_img));

bw1 = im2bw(f3,graythresh(f3));
%figure,imshow(bw1);
%-----------
D = bwdist(bw1);

%imshow(D,[]);
DL = watershed(D);
bgm =  DL == 0; %watershed ridge lines (background markers, bgm)
%calculate the watershed transform of the segmentation function
figure,imshow(bgm);
gradmag2 = imimposemin(gradmag,bgm|fgm);     % modify the image so that it only has ...
...regional minima at desired locations(here the reg. min need to occur only ...
...at foreground and background locations
L = watershed(gradmag2); % final watershed segmentation
%L == 0; % this is where object boundaries are located
Lrgb = label2rgb(L, 'jet', 'k', 'shuffle');
figure,imshow(I,[]);hold on
h = imshow(Lrgb);
h.AlphaData = 0.3;  % overlap the segmentation with the original image using transparency option of the image object 

% figure,imshow(I,[]);hold on
% I(imdilate(L == 0, ones(3, 3)) | bgm | fgm) = 255;% to se all, fgm, bgm and boundaried of the objects

%-------AN

