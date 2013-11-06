function [level, std0, bckgndI] = findBackgnd(img, fast)
% 
%   [level, std0, backgndImage] = backgndMedian(img, fast)
% 
% find the median and std of background pixels. Do generous imopen to eliminate
% cells from image before doing statistics.
%   fast = 1, do not fit non pdms regions to polynomial to define smooth bckgnd
%        = 0, do poly fit, much slower
%
% TODO should define std by +-std == 68.2, 95.5, 99.7% of pts around median, to ignore extreme
% outliers. In green channel the PDMS posts are less intense than culture medium
% without cells, should restrict backgnd to cell media only

global userParam

rdisk = round(sqrt(userParam.nucAreaHi/pi));
% remove the cells from image before doing stats.
bckgndI0 = imopen(img, strel('square', 4*rdisk+1));
if fast
    pts = double(bckgndI0(:));
    level = round(median(pts) );
    std0  = round(std(pts) );
    bckgndI = bckgndI0;
    return
end

pdms = maskPDMS(bckgndI0);

% fit polynomial of degree npoly for each row of data, need exclude PDMS.
% To speed up routine coarsen mesh and smooth and then expand, assume 'skip'
% evenly divides both dimensions

npoly = 2;
skip = 4;   %% skip=4 only gives 6x speed up.
img = bckgndI0(1:skip:end, 1:skip:end);
rows = pdms(1:skip:end, 1:skip:end);

[m,n] = size(img);
bckgndI = uint16(zeros(size(img)));
for i = 1:m
    row = rows(i,:);
    n1 = find( row==0, 1, 'first');
    n2 = find( row==0, 1, 'last');
    if( ~isempty(n1) && ~isempty(n2) && n2 > n1 + npoly + 2 )
        pp = polyfit(n1:n2, double(img(i,n1:n2)), npoly);
        bckgndI(i, 1:n) = polyval(pp, 1:n); %fit everything
    end
end

bckgndI = imresize(bckgndI, skip, 'bilinear');
bckgndI(pdms) = bckgndI0(pdms);
pts = double(bckgndI(~pdms));
level = round(median(pts ) );
std0  = round(std(pts ) );

return