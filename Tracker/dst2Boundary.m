function dst = dst2Boundary(xy, mask)
%
%   dst = dst2Boundary(xy, mask)
%
% min distance from boundary, construed to be at xy= 0, size(img)+1
% xy = x,y coordinates, pixel units, one per row,
% mask = size(img) OR 
% when use image of CCC, mask = 1 in boundary, 0 in fluid, used for dst transform.
% dst = column vector of min distance
%
% for test data xy in [0,1) real, use mask=[0,0];

pts = size(xy,1);
dst = zeros(pts, 1);

if length(mask) == 2
    xmax = mask(2)+1;
    ymax = mask(1)+1;
    for n = 1:pts
        dst(n) = min([xy(n,:), xmax-xy(n,1), ymax-xy(n,2)]);
    end
    if min(dst) < 1
        fprintf(1, 'WARNING in costMatrixEDS negative distances to boundary, input correct sizeImg, currently= %d %d\n',...
            mask);
    end
else
    %%%% need impose a 1 pixel border, in mask, so behavior off from above
    dd = bwdist(mask);
end
    