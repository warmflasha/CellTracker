function mask = pts2VoronoiMask(posx, posy, sizei)
% for a s collection of x,y points on an image of sizei compute voronoi
% decomposition and return a mask with polygons = 1 and the edges
% separating then =1.

posx = round(posx);
posy = round(posy);

% alternative strategy to use roipoly to build the polygons around each
% point by knowing which vertices go with which center using rgn(). Problem
% that not clear how edges to infinity drawn, see convxHull fn 
%[vrtc, rgn] = voronoin(posx, posy);
[vx, vy] = voronoi(posx, posy);

mask = vrtc2mask(vx, vy, sizei );

return

function mask = vrtc2mask(vx, vy, sizei)
% convert the lines joining vertices of voronoi polygons to mask. 
% Might try
% using voronoin() to get v. vertices bounding each point, convert to polygon
% shrink a bit and take negation.
    mask = false(sizei);
    
    x0 = round(vx(1,:));
    y0 = round(vy(1,:));
    x1 = round(vx(2,:));
    y1 = round(vy(2,:));
    
    for i = 1:length(x0)
        dltx = x1(i) - x0(i);
        dlty = y1(i) - y0(i);  
        dst = dltx^2 + dlty^2;
        if( dst > sizei.^2 )
            scl = sqrt( sizei.^2/dst );
            dltx = round(scl*dltx);
            dlty = round(scl*dlty);
        end
        if inside_mask(x0(i), y0(i), sizei) 
            [lx, ly] = ptsOnLine(dltx, dlty);
            lx = lx + x0(i);
            ly = ly + y0(i);
        elseif inside_mask(x1(i), y1(i), sizei)
            [lx, ly] = ptsOnLine(-dltx, -dlty);
            lx = lx + x1(i);
            ly = ly + y1(i);
        else  % case both vertices outside mask
            continue
        end
        [lx,ly] = limit2mask(lx, ly, sizei);
        lx = max(lx, 1);  ly = max(ly,1);  % bug in pts2line that can return 0
        pixel = sub2ind(sizei, ly, lx);
        mask(pixel) = 1;
    end
    
function [lx, ly] = limit2mask(lx, ly, sizei)
% given ~line of points on lattice, and assuming (lx(1), ly(1)) is inside
% of mask of size= sizei. Cut off the line to the last point within mask.

    iu = length(lx);
    if inside_mask(lx(iu), ly(iu), sizei)
        return;
    end
    % do log search
    il = 1;
    for jj = 1:100
        im = round( (il+iu)/2 );
        if inside_mask( lx(im), ly(im), sizei)
            il = im;
        else
            iu = im;
        end
        if (iu == il + 1)
            lx = lx(1:il);
            ly = ly(1:il);
            return;
        end
    end

function tf = inside_mask(x, y, sizei)
    if(x<1 || y<1)
        tf = 0;
        return
    end
    if(x>sizei(2) || y>sizei(1) )
        tf = 0;
        return
    end
    tf = 1;
        