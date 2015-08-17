%% code to use watershead marker-based segmentation to separate the nucleus from cytoplasm
function [L,stats] = Watershedsegm(I,I2)

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
 %-------AN

h = fspecial('sobel');
Ix  = imfilter(double(normed_img),h,'replicate'); %NEED to use nuc channel here
Iy  = imfilter(double(normed_img),h','replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);% this is the image where the dark regions are objects to be segmented (?) doublecheck
%  need to mark the forground objects there
% se = strel('disk',diskrad);
% Ie = imerode(I,se);
% Iobr = imreconstruct(Ie,I);
% Iobrd = imdilate(Iobr,se);
% Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
% Iobrcbr = imcomplement(Iobrcbr);
% fgm = imregionalmax(Iobrcbr);

l = graythresh(normed_img);      % marking the foreground objects(fgm)
bw1 = im2bw(normed_img,l);
%------
% cc = bwconncomp(bw1);              % try to eliminate the small bright objects at this point
% m = labelmatrix(cc);
% stats = regionprops(cc,'Area');
% A = stats.Area;
% arealo = 1000;
% if any(A < arealo);
% nim=normed_img-bw1;  % need to have here bw1 subtracted from the binary image, not grey
% l = graythresh(nim);
% bw1 = im2bw(nim,l);
% end
% figure,imshow(bw1);
%--------
fgm = imregionalmax(bw1); % marking the foreground objects(fgm)
figure,imshow(fgm);
%now marking the background objects( in the normed_img the dark pixels belong to the background)
%bw = im2bw(normed_img, graythresh(normed_img));
%--------preprocess the non-nuc channel
nuc = I2;
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

bw2 = im2bw(normed_img, graythresh(normed_img));
%----end preprocess the non nuc channel

D = bwdist(bw1);
D2 = bwdist(bw2-bw1);
%imshow(D,[]);
DL = watershed(D2);
bgm =  DL ==0; %watershed ridge lines (background markers, bgm)
%calculate the watershed transform of the segmentation function
gradmag2 = imimposemin(gradmag,bgm|fgm);     % modify the image so that it only has ...
...regional minima at desired locations(here the reg. min need to occur only ...
...at foreground and background locations
L = watershed(gradmag2); % final watershed segmentation
%L == 0; % this is where object boundaries are located
Lrgb = label2rgb(L, 'jet', 'r', 'shuffle');
figure,imshow(I2,[]);hold on
h = imshow(Lrgb);
h.AlphaData = 0.3;  % overlap the segmentation with the original image using transparency option of the image object 

figure,imshow(I2,[]);hold on
I(imdilate(L == 0, ones(3, 3)) | bgm | fgm) = 255;% to se all, fgm, bgm and boundaried of the objects

%-------AN

% threshold and find objects
thresh = 0.04; arealo = 1000;

nthresh = normed_img > thresh;

cc =bwconncomp(nthresh);

stats = regionprops(cc,'Area','Centroid');

 badinds = [stats.Area] < arealo; %make the image where only the removed areas are present; then subtract it from nthresh = image mask without bright small stuff
 stats(badinds) = [];

xy = [stats.Centroid];
xx=xy(1:2:end);
yy=xy(2:2:end);

figure; imshow(nuc,[]); hold on;
plot(xx,yy,'r*');