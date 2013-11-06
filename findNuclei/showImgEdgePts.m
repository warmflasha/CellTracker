function showImgEdgePts(img, edge, pts)
%
%   showImgEdgePts(img, edge, pts)
%
% show a RGB or gray scale image with edges and points superimposed.
%   edges are a binary image with 1 on edge pixels Multiple edges are passed 
% in as cat(3, edge1, edge2,..) 
%   The pts are passed in as cell array, pts{i} = xy(:,2), or if only one 
% set just as xy(:,2). 
%   Multiple edges or sets of points displayed as r, g, m. 
%   Can skip any input other than img by passing in []
%   The ugly edge boundaries can be made smaller adjusting 'MarkerSize' in
% plot(rescale*col, rescale*row, [colors(i) '.'], 'MarkerSize', 5 ), but
% problems with magnified images.

colors = ['r', 'g', 'm', 'y'];
rescale = 1;
if( size(img,1) >= 1024)
    rescale = 0.5;
    rescale = 1.;
    img = imresize(img, rescale, 'nearest');
end
nedge = size(edge, 3);
npts = length(pts);
if( npts && ~iscell(pts) )
    npts = 1;       % one xy array input directly not as cell
end

imshow(img,[]);  % doing imadjust expands to 0-2^16

hold on;   
for i = 1:nedge
    [row, col] = find(edge(:,:,i));
    if length(row) > 0
        plot(rescale*col, rescale*row, [colors(i) '.'], 'MarkerSize', 5 );
    end
end
for i = 1:npts
    if iscell(pts)
        xy = pts{i};
    else
        xy = pts;
    end
    if length(xy) > 0
        plot(rescale*xy(:,1), rescale*xy(:,2), [colors(i) '.'] )
    end
end
hold off;
