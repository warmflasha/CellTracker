function stats = addVoronoiPolygon2Stats(stats, sizei)
% add a field .VPixelIdxList giving the linear indices of pixels in voronoi polygon
% for the nucleus(i) placed in a matrix specified by sizei. Union of all
% ploygons is entire matrix, unless shrink=1

global userParam

verbose = 0;  
shrink_poly = 1;    
xy = stats2xy(stats);  % nb rounds to int.
% add dummy points far from array to resolve pts at infinity
scl = 10;
ptr = length(stats);
for i = -1:1
    for j = -1:1
        if( i || j )
            ptr = ptr + 1;
            xy(ptr,1) = scl*i*sizei(2);
            xy(ptr,2) = scl*j*sizei(1);
        end
    end
end
[vtx, cell] = voronoin(xy);

for i = 1:length(stats)
    pts = cell{i};
    if find(pts==1)
        fprintf(1, 'WARNING addVoronoiPolygon2Stats() finds vertex==Inf for cell= %d\n', i);
        xy(i,:)
        vtx(pts,:)
    end
    polyx = vtx(pts, 1);
    polyy = vtx(pts, 2);
%     bw = poly2mask(polyx, polyy, sizei(1), sizei(2) );
%     if shrink_poly
%         bw = imerode(bw, strel('disk', 1));
%     end
%     stats(i).VPixelIdxList = find(bw)';
    pxl = mask1polygon(polyx, polyy, sizei);
    if isfield(userParam, 'limitVoronoi') && userParam.limitVoronoi
        radius2 = userParam.nucAreaHi/pi;
        pxl = limitPts2Circle(pxl, xy(i,:), radius2, sizei);
    end
    stats(i).VPixelIdxList = reshape(pxl, 1, []);
end

if verbose
    bw = false(sizei);
    bw( [stats.VPixelIdxList] ) = 1;
    showImgEdgePts(bw, [], xy(1:length(stats),:) );
    title('voronoi polygons and centers of nuclei');
end
return 

function pixels = mask1polygon(ptx, pty, sizei)
% given x,y vertices of polygon in array of sizei, cutout bounding rectangle and
% construct mask, return pixels in coordinates of sizei

minx = floor(min(ptx));    miny = floor(min(pty));
m = ceil(max(pty));         n = ceil(max(ptx));

if( minx<1 || miny<1 || m>sizei(1) || n>sizei(2) )
    bw = poly2mask(ptx, pty, sizei(1), sizei(2) );  % this option alone takes 60% time
    bw = imerode(bw, strel('disk', 1));
    pixels = find(bw)';
    return
end

ptx = ptx - minx + 1;   pty = pty - miny + 1;
m = ceil(max(pty));     n = ceil(max(ptx));

bw = poly2mask(ptx, pty, m, n);
bw = imerode(bw, strel('disk', 1));
[row, col] = find(bw);
row = row + miny - 1;   col = col + minx - 1;
pixels = sub2ind(sizei, row, col);
return

function pts = limitPts2Circle(pts, xy, radius2, sizei)
% limit pts to radius^2 around center xy
[ii,jj] = ind2sub(sizei, pts);
dst = (ii - xy(2)).^2 + (jj - xy(1)).^2;
pts(dst > radius2) = [];
return