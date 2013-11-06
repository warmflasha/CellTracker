
function [ix, iy] = ptsOnLine( xin, yin )

% compute coordinates on lattice that approx a line from (0,0) to (x,y)
% return as  row(), then col().  Note if input (row, col) get (row, col)
% out, ibid for (x,y)

imax = abs( xin );   
jmax = abs( yin );
flipflag = 0;

if(imax < jmax)
    flipflag = jmax;
    jmax = imax;
    imax = flipflag;
end
if(imax < 1)
    ix(1) = 0;  iy(1) = 0;
    return;
end

% xmax >= ymax, project along x-axis, and find +- y grid pts
slope = jmax/imax;
pts = 1;
ix(1) = 0;  iy(1) = 0;  
for i = 1:imax
    pts = pts + 1;
    y = i*slope;
    ix(pts) = i;
    iy(pts) = floor(y);
    if(y > iy(pts))
        pts = pts + 1;
        ix(pts) = i;
        iy(pts) = iy(pts-1) + 1;
    end
end

if(flipflag)
    temp = ix;
    ix = iy;
    iy = temp;
end

% reflect x,y if signs of ix,iy points warrant.
if( xin < 0)
    ix = -ix;
end
if( yin < 0)
    iy = -iy;
end
return;
