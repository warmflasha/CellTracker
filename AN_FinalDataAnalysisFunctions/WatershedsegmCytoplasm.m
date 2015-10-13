function [statsnuc,statscyto,Lnuc,Lcyto] = WatershedsegmCytoplasm(I,I2,se,flag)
% first argument I is the nuclear channel image
% second argument I2 = is the cytoplasmic channel
% 
% se is the structuring element used in nuclear watershed ( need to put it
% in the userPram file);
% flag = if on (flag == 1) then you will see the figure with labeled
% objects, makes a subplot with nuclear and cytoplasmic images and objects

[Lnuc] = Watershedsegm(I,se);
c = bwconncomp(Lnuc);
nuc_objects = c.NumObjects;
bw = Lnuc ;
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
low_thresh = 500;
    
nuc(nuc < low_thresh)=0;
norm = imdilate(nuc,strel('disk',diskrad));
normed_img = im2double(nuc)./im2double(norm);
normed_img(isnan(normed_img))=0;
%figure,imshow(normed_img);

% threshold and find objects
thresh = 0.04; arealowcyto = 2000;%3200  to filter out the non cytoplasmic stuff ( further in the code)
               areahicyto = 13000;%20000
 nthresh = normed_img > thresh;
% imshow(nthresh);
 t = bw+nthresh;
 t = im2bw(t);
 
 se2 = strel('disk',11);%11 % if some cytoplasms of neighboring objects are touching, this will separate them so that the 
 % segmentation actually results in two objects rather then one merged
 % cytoplasm of two cells
 sep = imopen(t,se2);
 
 t2 = bwareafilt(sep,[arealowcyto areahicyto]);% remove the small stuff based on the area
 
 I3 = im2double(t2);
 
 fgm = imregionalmax(t2);
% figure,imshow(fgm);

h = fspecial('sobel');
Ix  = imfilter(I3,h,'replicate'); %double(normed_img) 
Iy  = imfilter(I3,h','replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);% this is the image where the dark regions are objects to be segmented (?) doublecheck
%figure, imshow(gradmag);

%now marking the background objects( in the normed_img the dark pixels belong to the background)

D = bwdist(t2);% t2
%figure,imshow(D);title('distance transform');
DL = watershed(D);
bgm =  DL == 0; %watershed ridge lines (background markers, bgm)

%figure,imshow(bgm);title('background markers');
gradmag2 = imimposemin(gradmag,bgm|fgm);     % modify the image so that it only has ...
                                              ...regional minima at desired locations(here the reg. min need to occur only ...
                                              ...at foreground and background locations
 Lall = watershed(gradmag2); % final watershed segmentation
%L == 0; % this is where object boundaries are located
 lblcyto = Lall> 1;
 S = bw + lblcyto;
 S = im2bw(S);
 Lcyto = S-bw;
 
 c2 = bwconncomp(Lcyto);
 %r2 = regionprops(c2,'Centroid','Area');
 cyto_objects = c2.NumObjects;
 
 if cyto_objects < nuc_objects || cyto_objects > nuc_objects
     Lcyto = im2bw(Lcyto);
     Lcyto = bwareafilt(Lcyto,[arealowcyto areahicyto]);
 end
     c2 = bwconncomp(Lcyto);
     cyto_objects_new = c2.NumObjects;

 Lcyto = bwlabel(Lcyto,8); % convert back to the label matrix in order to match the correct nuc to the correct cyto
 Lnuc = bwlabel(Lnuc,8); % same
 
 % show which objects are labeled in the final watershed segmentation in nuc
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
 
 % get the nuclear mean intensity for each labeled object (USE THE GFP
 % CHANNEL HERE AS 'I' SINCE NEED TO DETERMINE THE MEAN INTENSITY IN THE SAME
 % CHANNEL
 cc_nuc = bwconncomp(Lnuc); 
 statsnuc = regionprops(cc_nuc,I2,'Area','Centroid','PixelIdxList','MeanIntensity'); % statst for the nuc 'area' in cyto channel
 statsnuc_nuc = regionprops(cc_nuc,I,'Area','Centroid','PixelIdxList','MeanIntensity'); % stats for the nuclear channel
 aa = [statsnuc.Centroid];
 Inucchan  = [statsnuc.MeanIntensity];
 ar = [statsnuc.Area]; % nuclear area in cyto channel
 xnuc = aa(1:2:end);
 ynuc = aa(2:2:end);

 % get the cytoplasmic mean intensity for each labeled object
 cc_cyto = bwconncomp(Lcyto);
 statscyto = regionprops(cc_cyto,I2,'Area','Centroid','PixelIdxList','MeanIntensity');
 aa = [statscyto.Centroid];
 xcyto = aa(1:2:end);
 ycyto = aa(2:2:end);
 
 %final stats for the ratio; obtained from the same channel; nuc channel
 %here is necessary only the get the boundaries of the nuclei
 nucmeanInt  = [statsnuc.MeanIntensity];
 cytomeanInt  = [statscyto.MeanIntensity];
 
 %outdat = [xnuc' ynuc' ar'  Inucchan' nucmeanInt' cytomeanInt' ];
end

