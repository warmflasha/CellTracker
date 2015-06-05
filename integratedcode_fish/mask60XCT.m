function LcFull = mask60XCT (ff, i)


%% Creating masks for 60X images
% i = position

%% read file


%find the z position with maximum intensity.


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
low_thresh = 500;

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

%% save results

figure('visible', 'off');
imshow(zeros(1024,1024));
hold on;

[vx, vy] = voronoi(cen(:,1), cen(:,2));
plot(vx, vy, 'w');


fim = getframe(gca);

fim = frame2im(fim);


bfim = im2bw(fim); % converting to binary image
cbfim = imcomplement(bfim); %taking complement (masks are labelled other way round)

rcbfim = imresize(cbfim, [1024 1024]); 
LcFull = bwlabel(rcbfim,4);

%%
% removing discrepancies between LcFull and cen (if any)

cent = size(cen,1);
l1 = length(unique(LcFull));
l2 = l1-1;
diff = l2-cent;



if (diff > 0)
rLcFull = size(LcFull,1);
cLcFull = size(LcFull,2);

for ii=1:l2
    area(1,ii)=sum(sum(LcFull==ii));
end

[arsort, idx] = sort(area);


for i3 = 1:diff
    for i1 = 1:rLcFull
       for i2 = 1:cLcFull
        
        
            if (LcFull(i1,i2) == idx(i3))
                LcFull(i1,i2) = 0;
            end
        end
    end
end


end

%close all;

% file = sprintf('fishsegtest4_%02d.mat', i+1);
% fn = strcat(dire, '/masks/', file); 
% 
% save(fn,'LcFull');

% just to save images having detected cells
% imshow(nuc_o,[]);hold on; plot(cen(:,1),cen(:,2),'r*');
% title('Original Image with cells identified');
% 
% cid = getframe(gca);
% cid = frame2im(cid);
% 
% f = sprintf('cid%02d', i);
% fn = strcat(dire, '/cellid/', f, '.tif'); 
% 
% imwrite(cid, fn);


