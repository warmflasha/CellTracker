function [avrI, stdI, stdDlt] = backgndNoise(img, backgnd_mask)
% for an image and mask=1 in background, compute the mean of background, 
% the std, and the std of difference between adjacent pixels (which should
% be best measure of instrumental noise

mask = imerode(backgnd_mask, strel('square',3));

data = double(img(mask));
avrI = round(mean(data));
stdI = std(data);

[row, col] = find(mask);
pts = (row>1);
row = row(pts);  col = col(pts);
pts = (col>1);
row = row(pts);  col = col(pts);
pts = sub2ind(size(mask), row, col);
data = img(pts) - img(pts - 1);
data = [data; (img(pts) - img(pts - size(mask,1)) ) ];
stdDlt = std(double(data) );

return