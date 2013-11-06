function [cut, corner, width] = cutout_from_img(img, corner, width)
% do not extend region beyond image, reset width if necessary.
% corner is upper left [x,y], width is [dlt-x, dlt-y]
    [row, col] = size(img);
    corner = max(corner, 1);
    rows = corner(2):min(row, corner(2)+width(2)-1);
    cols = corner(1):min(col, corner(1)+width(1)-1);
    cut = img( rows, cols );
    width = [size(cut,2), size(cut,1)];
