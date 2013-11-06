function cells = addSplines2Cells(cells)
%
% cells = addSplines2Cells(cells)
%
% Take cells.fdata and add fields 
%   sdata   spline smoothed version of fdata, same format
%   splines the spline coefs one for each col of sdata (pp=csaps(..))
% 
% The spline fit is done relative to onframes as x coordinate
%
% The spline routine will eliminate fluor==0 points and other bad data points based on
% difference between data and spline fit relative to rms difference.
% Recompute the splines with weight==0 for all fluor==0 AND bad pts
%   xstd    defines 'bad pts', = number of times std the point is from
%           spline fit
%

global userParam

ncol = size(cells(1).fdata, 2);
sp = userParam.splineparam;
% pts more than xstd*std(smooth spline - data) are dropped
xstd = 4;
% flag=1 ->do not compute splines for cells.good=0, ie too short
flag_skip_minlength = 0; % does not save much time.

% various error counts in loop, printed at end
nbad = 0;   nnbad = 0;   badcol = 0;   allpts = 0;   pctnnbad = 0.10; 

for ncell = 1:length(cells)
% old AW stuff to trim all data, need update for new fields.
%     of=cells(cellnum).onframes;
%     uf=of(ismember(of,useframes));
%     cells(cellnum).onframes=uf;
%     cells(cellnum).data=cells(cellnum).data(uf,:);

    xx = cells(ncell).onframes;
    if flag_skip_minlength && length(xx) < userParam.minlength
        continue
    end
    
    sdata = zeros(size(cells(ncell).fdata) );
    for nc = 1:ncol 
        [sdata(:,nc), cells(ncell).splines(nc), badpts] = ...
            smooth_spline(xx, cells(ncell).fdata(:,nc), sp, xstd);
        nbad = nbad + badpts;
        if badpts 
            badcol = badcol + 1;
        end
        if badpts > pctnnbad*length(xx)
            nnbad = nnbad + 1;
        end
    end
    allpts = allpts + ncol*length(xx);
    cells(ncell).sdata = sdata;
end

if userParam.verboseCellTrackerEDS >=1
    fprintf(1, 'addSplines2Cells: sp-param= %d, ncells= %d, pts splined= %d bad pts= %d omitted\n',...
        sp, length(cells), allpts, nbad);
    fprintf(1, '  fluor-data cols (>0 bad pts)= %d, cols with>%d pct bad pts= %d\n',...
        badcol, round(100*pctnnbad), nnbad);
    fprintf(1, '  abs(splines - data)> %d*rms_error are bad pts and omitted in spline fits\n', xstd);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [syy, pp, nbad] = smooth_spline(xx, yy, sp, xstd)
% smoothing splines on yy(xx) using sp as spline parameter. 
% Ignore pts with value==0. 
% Drop points more than xstd away from std of data from smoothed spline fit.

wt = ones(size(yy));
is0 = (yy==0);
% case most of data==0, assume its all==0 and kill cell later
if sum(is0)>=(length(yy)-2)
    syy = zeros(size(yy));
    pp = csaps(xx, yy, sp);
    nbad = length(yy);
    return;
else
    wt(is0) = 0;
end
pp = csaps(xx, yy, sp, [], wt);
syy = fnval(pp, xx);
syy = reshape(syy, size(yy));
rmserr = std( syy(~is0)-yy(~is0) );

badpts = (abs(syy - yy) > xstd*rmserr);
nbad = sum(badpts);
% if only bad points those with yy=0, then syy and pp, ok
% if all points bad, there would be no != wt's so return
if nbad < 1 || nbad==sum(is0) || nbad>=length(yy)-2 
    return
end
wt = ones(size(yy));
wt(badpts) = 0;
pp = csaps(xx, yy, sp, [], wt);
syy = fnval(pp, xx);
syy = reshape(syy, size(yy));
return