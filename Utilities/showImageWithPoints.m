function stats = showImageWithPoints(img,mask)

binmask = mask > 0;

stats = regionprops(binmask,mask,'Area','Centroid','MeanIntensity');

xy = stats2xy(stats);

showImgAndPoints(img,xy); 
mean_int = [stats.MeanIntensity];

for ii = 1:length(mean_int)
text(xy(ii,1),xy(ii,2)+10,int2str(mean_int(ii)),'Color','m');
end