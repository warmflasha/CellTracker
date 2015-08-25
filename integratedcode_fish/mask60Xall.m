function LcFull = mask60Xall(ff,i)


% ff = readAndorDirectory('.');
% st = ff.p(1);
% l = length (ff.p)-1; %% l: reference to the last position 

 

%%
%for i = st:l
nuc = andorMaxIntensity(ff,i,0,0);
nuc_o = nuc;

level = graythresh(nuc);
im1 = im2bw(nuc, level);
im2 = imerode(im1, strel('disk', 2)); 
im3 = imdilate(im2, strel('disk', 15));

im4 = bwlabel(im3, 4);

mlabel = max(max(im4));

 dilfact = 2;
 
while (mlabel >1)
   
    im3 = imdilate(im3, strel('disk', dilfact));
    dilfact = dilfact*2;
    im4 = bwlabel(im3, 4);
    mlabel = max(max(im4));
    
end

LcFull = im4;

% figure; 
% imshow(nuc);

% figure;
% imshow(im1);
% 
% figure;
% imshow(im2);

% figure;
% imshow(im3);
%end