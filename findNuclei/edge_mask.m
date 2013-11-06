function edge = edge_mask(mask)
% compute the edge of binary and return as logical
% MATLAB 2010a bug on MAC need apply imdialte to bwpack data, otherwise use
% separable strel.
ss = strel('square', 3);
edge = imdilate(mask, ss) & ~mask;  % thicker lines with -imerode(mask, ss);
%ss = strel('disk', 1);
%edge = bwunpack(imdilate(bwpack(mask), ss)) & ~mask;  % thicker lines with -imerode(mask, ss);