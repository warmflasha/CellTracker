%%
%Checking if segmentation works fine. 
%Creating masks for 60X images
%read file
%Maximising the intensity of DAPI channel to get better segmentation.
%The file to be read should be in the current path. 

% i = position

clear all;

ff = readAndorDirectory('.');
st = ff.p(1);
l = length (ff.p)-1; %% l: reference to the last position 

  

%%
for i = st:l
nuc = andorMaxIntensity(ff,i,0,0);
nuc_o = nuc;

%% preprocess
global userParam;
userParam.gaussRadius = 1;
userParam.gaussSigma = 1;
userParam.small_rad = 3;
userParam.presubNucBackground = 1;
userParam.backdiskrad = 300;

nuc = imopen(nuc,strel('disk',userParam.small_rad)); % remove small bright stuff
nuc = smoothImage(nuc,userParam.gaussRadius,userParam.gaussSigma); %smooth
nuc =presubBackground_self(nuc);

%%  Normalize image
diskrad = 100;
low_thresh = 1000;

nuc(nuc < low_thresh)=0;
norm = imdilate(nuc,strel('disk',diskrad));
normed_img = im2double(nuc)./im2double(norm);
normed_img(isnan(normed_img))=0;


%% gradient image
hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(normed_img), hy, 'replicate');
Ix = imfilter(double(normed_img), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);
%% circle find and display
%[cc, rr, met]=imfindcircles(gradmag,[20 40],'Method','TwoStage','Sensitivity',0.95);
[cc, rr, met]=imfindcircles(gradmag,[20 40],'Method','TwoStage','Sensitivity',0.95);
%throw out circles with nothing inside
cavg = zeros(length(rr),1);
for ii=1:length(rr)
[cavg(ii), mm]=averageImageInCircle(nuc,floor(cc(ii,:)),rr(ii));
end
badinds = cavg < 1000;
cc(badinds,:)=[]; rr(badinds,:)=[];

% convert circlees to cells (will merge close circles) 
cen = circles2cells(cc,rr);

%%

figure;
showImg({nuc_o});hold on; plot(cen(:,1),cen(:,2),'r*');
end
% title('Original Image with cells identified');
% 
% cid = getframe(gca);
% cid = frame2im(cid);
% 
% 
% f = strtok(drinfo(i+diffnum).name,'.');
% fn = strcat(dire, '/celldet/', f, '.tif'); 
% 
% imwrite(cid, fn);
% close all;
% 


