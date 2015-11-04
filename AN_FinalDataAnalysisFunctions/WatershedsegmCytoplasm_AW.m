%% code to use watershead marker-based segmentation to separate the nucleus from cytoplasm
function [Lcyto] = WatershedsegmCytoplasm_AW(Lnuc,I2)

% I2 = imread('SingleCellSignalingAN_t0000_f0019_z0003_w0001.tif');% gfp channel (gfp-smad4 cells)
% 
% nuc = I;
% % preprocess
% global userParam;
% userParam.gaussRadius = 10;
% userParam.gaussSigma = 3;
% userParam.small_rad = 3;
% userParam.presubNucBackground = 1;
% userParam.backdiskrad = 300;
% 
% nuc = imopen(nuc,strel('disk',userParam.small_rad)); % remove small bright stuff
% nuc = smoothImage(nuc,userParam.gaussRadius,userParam.gaussSigma); %smooth
% nuc =presubBackground_self(nuc);
% %  Normalize image
% diskrad = 100;
% low_thresh = 500;
% 
% nuc(nuc < low_thresh)=0;
% norm = imdilate(nuc,strel('disk',diskrad));
% normed_img = im2double(nuc)./im2double(norm);
% normed_img(isnan(normed_img))=0;
% 
% % threshold and find objects
% thresh = 0.04; arealo = 1000; 
% 
% nthresh = normed_img > thresh;
% 
% cc =bwconncomp(nthresh);
% 
% stats = regionprops(cc,'Area','Centroid');
% 
% badinds = [stats.Area] < arealo;
% stats(badinds) = [];
% 
% xy = [stats.Centroid];
% xx=xy(1:2:end);
% yy=xy(2:2:end);
% 
% %figure; imshow(nuc,[]); hold on;
% %plot(xx,yy,'r*');
% %AN
% % create the image to input into the watershed segmentation process based
% % on the segmentation done above
% 
% Inew = zeros(1024,1024);
% for k=1:length(xx)
%     Inew(int32(yy(k)),int32(xx(k))) = 1;
% end
% %figure,imshow(Inew);
% se = strel('disk',se);
% Inew = imdilate(Inew,se);
% %imshow(Inew);
%
% here can start from imported masks from the Ilastik file
fgm = imregionalmax(Lnuc);%

%figure,imshow(fgm); title('foreground');

% h = fspecial('sobel');
% Ix  = imfilter(double(normed_img),h,'replicate'); 
% Iy  = imfilter(double(normed_img),h','replicate');
% gradmag = sqrt(Ix.^2 + Iy.^2);
%figure, imshow(gradmag);

D = bwdist(Lnuc);%bw1

%imshow(D);
DL = watershed(D);
bgm =  DL == 0; %
%fgm = imdilate(Lnuc,strel('disk',2));

% gradmag2 = imimposemin(gradmag,bgm|fgm);
% L = watershed(gradmag2); % final watershed segmentation

% Lnuc = L >1;
% arealownuc = 1000;
% areahinuc = 8000;
% Lnuc = bwareafilt(Lnuc,[arealownuc areahinuc]);

% cytoplasmic channel analsis
nuc = I2;
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
 diskrad = 100;%100
 low_thresh = 300;%300
% 
 nuc(nuc < low_thresh)=0;
 norm = imdilate(nuc,strel('disk',diskrad));
 normed_img = im2double(nuc)./im2double(norm);
 normed_img(isnan(normed_img))=0;
%normed_img = nuc; 
h = fspecial('sobel');
Ix  = imfilter(double(normed_img),h,'replicate');
Iy  = imfilter(double(normed_img),h','replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);%

%fgm = imerode(Lnuc,strel('disk',2));

fgm = imdilate(Lnuc,strel('disk',1));
% fgm = imclose(fgm,strel('disk',3));%AN

 gradmag2 = imimposemin(gradmag,bgm|fgm);
L = watershed(gradmag2); % final watershed segmentation

Lcyto = L > 1 & ~Lnuc;
%cc = bwconncomp(Lcyto,8);

%Lcyto = bwareafilt(Lcyto,[arealowcyto areahicyto]);
%figure; imshow(Lcyto);


end


