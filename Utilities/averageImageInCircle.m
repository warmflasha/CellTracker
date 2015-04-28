function [avg, mask]=averageImageInCircle(img,cen,r)

y=floor(cen(1)); x=floor(cen(2));

mask=zeros(size(img));
mask(x,y)=1;
mask=bwdist(mask);
mask = mask < r; 
avg=mean(img(mask));
end
