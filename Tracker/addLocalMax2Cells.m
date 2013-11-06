function cells = addLocalMax2Cells(cells)
%
% For all cells with cells().good = 1, compute a cell array with local max
% for selected columns of cells().sdata(:, col2lmax). Add new field to
% cell array, cells:
%
%   lmaxcell{col2lmax}
% 
% optionally include other lmaxcell{} corresponding to nuc/cyto ratio for
% smads.
%
% Two options to find local max: ddata2lmaxStruct() or data2lmaxStruct()
% set by flag below. The former computes the slope of data using splines
% and puts various restrictions on what is valid local max, latter looks
% only at the spline fit data and finds all local max (via extrema()). Both routines ignore
% local max at end points.
%
% each lmaxcell is itself a struct array with the local max enumerated and
% various properties collected for the local max as defined in
% ddata2lmaxStruct() or data2lmaxStruct
%
% the min value of fluor data is set to 0 ie <0 not allowed
%
% can also create a all_lmax struct array which cat together the lmax of a
% given type for all the cells, so as to plot stats, CURRENTLY do this in
% statsLocalMax()
%

global userParam

% for lmax based on data and not deriv use this, otherwise any string 
% lmax_finder = 'ddata';
lmax_finder = 'data_only';

% columns of fdata, sdata to compute lmaxcell{}. If negative do all columns
col2lmax = 1:3; 
if col2lmax(1) < 1;
    col2lmax = 1:size(cells(1).fdata, 2);
end

sp = userParam.splineparam;
for nc = 1:length(cells)
    if ~cells(nc).good
        continue
    end 

    xx = cells(nc).onframes;
    for col = col2lmax
        data = max(cells(nc).sdata(:,col), 0);
        if strcmp(lmax_finder, 'data_only');
            cells(nc).lmaxcell{col} = data2lmaxStruct(xx, data );
        else
            ddata = deriv_spline(xx, cells(nc).splines(col) );
            cells(nc).lmaxcell{col} = ddata2lmaxStruct(xx, data, ddata );
        end
    end

    % ratio of nuc to cyto fluor
    data23 = cells(nc).sdata(:,2) ./ cells(nc).sdata(:,3);
    data23 = max(data23, 0);
    % case of all spline data==0 not good cell,but miscalled
    if min(data23) > 1.e10
        cells(nc).lmaxcell{col+1} = [];
        continue
    end
    if strcmp(lmax_finder, 'data_only');
        cells(nc).lmaxcell{col+1} = data2lmaxStruct(xx, data23 );
    else
        pp = csaps(xx, data23, sp);
        ddata23 = deriv_spline(xx, pp);
        cells(nc).lmaxcell{col+1} = ddata2lmaxStruct(xx, data23, ddata23 );
    end
    nclast = nc;
    %clear data ddata data23 ddata23
end 

% fprintf(1, 'addLocalMax2Cells: added len %d lmaxcell{} to good cells, using max finder= %s\n',...
%     length(cells(nclast).lmaxcell), lmax_finder );
   
function ddata = deriv_spline(xx, pp)
% compute deriv of data where pp = csaps(xx, data, sp);
dpp = fnder(pp);
ddata = fnval(dpp, xx);
ddata = reshape(ddata, [], 1);
return

