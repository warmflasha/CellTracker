function  vImg = mkVoronoiImageFromPts(xy, sizei)
% 
xy = round(xy);
% add dummy points far from array to resolve pts at infinity
scl = 10;
ptr = size(xy,1);
orig_size = ptr;
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
% if vtx(1,1) == Inf
%     vtx(1,:)=[];
% end

VPixelIdxList = [];
for i = 1:orig_size
    pts = cell{i};
    if find(pts==1)
        fprintf(1, 'WARNING mkVoronoiImageFromPts() finds vertex==Inf for cell= %d\n', i);
        xy(i,:)
        vtx(pts,:)
    end
    polyx = vtx(pts, 1);
    polyy = vtx(pts, 2);

    pxl = mask1polygon(polyx, polyy, sizei);

    VPixelIdxList = [VPixelIdxList reshape(pxl, 1, [])];
    
    
    
end

vImg = ones(sizei);
vImg(VPixelIdxList) = 0;


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