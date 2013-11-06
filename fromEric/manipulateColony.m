function manipulateColony(directory, keyword, colony)
% read from data directory, the outall.mat file and extract the images
% corresponding to the keywords (eg {'w1', ..}) in the cell array keyword
% for indicated colony.
%
% option to mark circle for computed boundary, using data from colonies.

matfile = [directory, filesep, 'outall.mat'];
dd = load(matfile, 'colonies');
img = assembleColony(directory, keyword, matfile, colony, 0);
colony = dd.colonies(colony);

% temporary kluge to translate from plate coordinates to colony coordinates
min_img_index = min(colony.data(:,end-1));
dd = load(matfile, 'acoords');
origin0 = dd.acoords(min_img_index).absinds - [1,1];  % base 0
origin0xy = [origin0(2), origin0(1)];

center = round( colony.center ) - origin0xy;
radius = colony.radius;

% bndry = boundaryMask(img{1}, center, radius); 
% img0 = img{1};
% img0(bndry) = max(max(img0));
figure, imshow(img0, []);
hold on
plot(center(1), center(2),'cs','MarkerSize',20);
drawcircle(center, radius,'c');

% show nuclear centers
hold on
nuc = colony.data(:,1:2) - ones(colony.ncells,1)*origin0xy;
plot(nuc(:,1),nuc(:,2), '.r')
hold off

return

function [x,y] = plotNucCenters(colony, center)

% function bndry = boundaryMask(img, center, radius)
% % create a mask showing the radius bounding the colony
% pts = 2*pi*radius;
% theta = (1:pts)'*(2*pi/pts);
% [x,y] = pol2cart(theta, radius);
% x = round(x + center(1));
% y = round(y + center(2));
% indx = sub2ind(size(img), y, x);
% bndry = false(size(img));
% bndry(indx) = 1;
% dilate_rad = ceil(max(size(img))/1024);
% bndry = imdilate(bndry, strel('disk', dilate_rad));
% % figure, imshow(bndry)