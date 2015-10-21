%% code to use watershead marker-based segmentation to separate the nucleus from cytoplasm
function [Lnuc,Lcyto,nucmeanInt,cytomeanInt] = WatershedsegmCytoplasm_AW(I,I2,se,flag)

% I2 = imread('SingleCellSignalingAN_t0000_f0019_z0003_w0001.tif');% gfp channel (gfp-smad4 cells)
% I = imread('SingleCellSignalingAN_t0000_f0019_z0003_w0000.tif');% nuc chan
nuc = I;
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

stats = regionprops(cc,'Area','Centroid');

badinds = [stats.Area] < arealo;
stats(badinds) = [];

xy = [stats.Centroid];
xx=xy(1:2:end);
yy=xy(2:2:end);

%figure; imshow(nuc,[]); hold on;
%plot(xx,yy,'r*');
%AN
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

fgm = imregionalmax(Inew);%
%figure,imshow(fgm); title('foreground');

h = fspecial('sobel');
Ix  = imfilter(double(normed_img),h,'replicate'); 
Iy  = imfilter(double(normed_img),h','replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);
%figure, imshow(gradmag);

D = bwdist(Inew);%bw1

%imshow(D);
DL = watershed(D);
bgm =  DL == 0; %
%fgm = imdilate(Lnuc,strel('disk',2));

gradmag2 = imimposemin(gradmag,bgm|fgm);
L = watershed(gradmag2); % final watershed segmentation

Lnuc = L >1;
arealownuc = 1000;
areahinuc = 8000;
Lnuc = bwareafilt(Lnuc,[arealownuc areahinuc]);
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
diskrad = 100;
low_thresh = 200;%300
arealowcyto = 2000;
areahicyto = 20000;

nuc(nuc < low_thresh)=0;
norm = imdilate(nuc,strel('disk',diskrad));
normed_img = im2double(nuc)./im2double(norm);
normed_img(isnan(normed_img))=0;

h = fspecial('sobel');
Ix  = imfilter(double(normed_img),h,'replicate');
Iy  = imfilter(double(normed_img),h','replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);%

fgm = imdilate(Lnuc,strel('disk',1));

gradmag2 = imimposemin(gradmag,bgm|fgm);
L = watershed(gradmag2); % final watershed segmentation

Lcyto = L > 1 & ~Lnuc;
cc = bwconncomp(Lcyto,8);

Lcyto = bwareafilt(Lcyto,[arealowcyto areahicyto]);
%figure; imshow(Lcyto);

% AN: to show which objects are labeled in the final watershed segmentation in nuc
% lear and cyto channels; also show the final foreground markers
if flag == 1
    figure,imshow(fgm);
    Lrgb = label2rgb(Lnuc, 'jet', 'k', 'shuffle');
    figure,subplot(1,2,1),imshow(I,[]);hold on
    h = imshow(Lrgb);
    h.AlphaData = 0.3;
    Lrgbcyto = label2rgb(Lcyto, 'jet', 'k', 'shuffle');
    subplot(1,2,2),imshow(I2,[]);hold on
    h = imshow(Lrgbcyto);
    h.AlphaData = 0.3;
end

%AN  to get the stats from the obtained masks

Lcyto = bwlabel(Lcyto,8); % convert back to the label matrix in order to match the correct nuc to the correct cyto
Lnuc = bwlabel(Lnuc,8);
cc_nuc = bwconncomp(Lnuc);
statsnuc = regionprops(cc_nuc,I2,'Area','Centroid','PixelIdxList','MeanIntensity'); % statst for the nuc 'area' in cyto channel
statsnuc_nuc = regionprops(cc_nuc,I,'Area','Centroid','PixelIdxList','MeanIntensity'); % stats for the nuclear channel
aa = [statsnuc.Centroid];
Inucchan  = [statsnuc.MeanIntensity];
anuc = [statsnuc.Area]; % nuclear area in cyto channel
xnuc = aa(1:2:end);
ynuc = aa(2:2:end);

% get the cytoplasmic mean intensity for each labeled object
cc_cyto = bwconncomp(Lcyto);
statscyto = regionprops(cc_cyto,I2,'Area','Centroid','PixelIdxList','MeanIntensity');
acyto = [statscyto.Area];
xcyto = aa(1:2:end);
ycyto = aa(2:2:end);

%final stats for the ratio; obtained from the same channel; nuc channel
%here is necessary only the get the boundaries of the nuclei
nucmeanInt  = [statsnuc.MeanIntensity];

cytomeanInt  = [statscyto.MeanIntensity];


%outdat = [xnuc' ynuc' ar'  Inucchan' nucmeanInt' cytomeanInt' ];

end


