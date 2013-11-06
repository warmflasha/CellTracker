function out = test4TopCells(area, fluor, cutoff)
%
%   out = test4TopCells(area, fluor, cutoff)
%
% This test used by routines:
%   peaks = matchFramesEDS(peaks)
%   [min_top, std_bot] = cellsTopBottom(peaks)
%   C = costMatrixEDS(peaksold, peaksnew, dst_dummy, min_top, std_bot)
%
% It defines a function of (nuclear) area and fluor that is compared with a
% cutoff to define cells on top of CCC chamber ( >= cutoff -> on top)
%
% If cutoff = [] it computes the appropriate fn of area, fluor and returns
% value as array
% If cutoff = real, it compares the appropriate fn of area, fluor, compares 
% with cutoff and returns TF
%
out = area./fluor;
if ~isempty(cutoff)
    out = (out >= cutoff);
end