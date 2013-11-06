function lmax = data2lmaxStruct(xx, data)
%
%   lmax = data2lmaxStruct(data)
%
% compute local max via extrema function. Local max must be flaked by 2
% local mins (ie local max at first or last point does not count). Should
% apply to spline smoothed data. 
%
% return struct array with fields
%   frame   time (int frame) of local max
%   width_min    width based on diff of flanking local mins
%   max     value of data at max
%   min1    value of left local min
%   min2    value of right local min
%   max2    average of data at min, each side of max, 
%   jump    max/max(0, max2) - 1
%
% return the struct array as row, so that one can cat over cells

[xmax, imax, xmin, imin] = extrema(reshape(data, 1, []) );
allex = sort([imax, imin]);
nex   = length(allex);
% check that first and last points are counted as extrema
if allex(1)>1 || allex(end)<nex
    fprintf(1, 'WARNING data2lmaxStruct, extrema is missing first and last point %d %d\n',...
        allex(1), allex(end) );
end
% find first and last index in allex that corresp to a local max with 2
% surrounding local mins
if find(allex(1) == imax)
    i1 = 3;
else
    i1 = 2;
end
if find(allex(end) == imax)
    i2 = nex - 2;
else
    i2 = nex - 1;
end

lmax = [];
for ii = i1:2:i2
    ptr = (ii - i1)/2 + 1;
    lmax(ptr).frame = xx(allex(ii));
    lmax(ptr).width_min = xx(allex(ii+1)) - xx(allex(ii-1));
    lmax(ptr).max = data(allex(ii));
    lmax(ptr).min1 = data(allex(ii-1));
    lmax(ptr).min2 = data(allex(ii+1));
    lmax(ptr).max2 = (data(allex(ii+1)) + data(allex(ii-1)))/2;
    lmax(ptr).jump = data(allex(ii))/max(0, lmax(ptr).max2) - 1;
end
    
    