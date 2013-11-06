function births = filterBirthsSibs(births, cells)
%
%   births = filterBirthsSibs(births, cells)

% This routine will chose the best among multiple sibs, chosing the one
% with min (area./fluor) over a window of times. Also discards births with
% no sibs and reports various stats.
%
% Infelicities:
%
% empirically, births (fluor peaks) with multiple sibs are the result of
% tracking errors where the parent cell prior to fluor peak, does not
% divide but an adjacent cell does and the parent is mapped to one of the
% 2 sibs that just divided.  To be cured by using area in mapping cells.
%
% we are not checking that the cell trajectory corresponding to either 'birth'
% or sib actually starts at the birth time, thus due to tracking errors, one can
% have two cells labeled as [birth, sib] pair the birth time in the middle of
% trajectory for both. 
%
% there is double counting of 'birth' which are merely peaks in the nuclear
% fluorescence subject to various filters. Thus if nominal mother and sib both
% have peaks, both are counted. We do not check that sib of sib == mother in
% such cases, since unclear how to resolve


global birthNodeParam
window = max(ceil(birthNodeParam.dltTime/2), 2);

% find which births have sibling data
nb = length(births);
nsibs = zeros(1,10);
for i = 1:nb
    mm(i) = length(births(i).sibling);
    nsibs(mm(i)+1) = nsibs(mm(i)+1) + 1;
end
fprintf(1, '\nIn filterBirthSibs(), input births(peaks cell traj)= %d, number with 0,1..sibs= %d %d %d %d %d\n', nb, nsibs(1:5));

% for births with >1 sibling find the best one
for ic = find(mm>1)
    births(ic) = resolve_multi_sibs(births(ic), cells, window);
end
% rerun counter since resolve_multi_sibs can remove all sibs
% add the 'duplicate' field
for i = 1:nb
    mm(i) = length(births(i).sibling);
    births(i).duplicate = 0;
end

% diagnostic stuff
if birthNodeParam.verbose
    diagnostic_plot(births(mm==0), ' with no sibling');
    diagnostic_plot(births(mm>0), ' with sibling');
end

% only keeping births with exactly 1 sib at this point
[unique_cells, cells_and_sibs, births] = unique_births(births(mm>0), birthNodeParam.dltTime );
uq_births = sum( [births.duplicate] == 0 );

fprintf(1, '  %d births with sibling, %d sib cells among birth cells, %d unique births, number of unique cells among births+sibs= %d\n',...
    sum(mm>0), length(cells_and_sibs), uq_births, length(unique_cells) );

return

function birth = resolve_multi_sibs(birth, cells, window)
% Decide which of 2 or more sibs to keep at a given birth, using min
% area/fluor to detect births.
% sibs = struct( cellN, time, dst )
%
global birthNodeParam

sibs = birth.sibling;
all_cells = [birth.cellN, [sibs.cellN]];
for ic = 1:length(all_cells)
    cellN = all_cells(ic);
    frames = cells(cellN).onframes;
    ptr = find(frames == birth.time);
    if isempty(ptr)  % new cell can appear just after birth.time of parent
        ptr = find(frames == (birth.time - birthNodeParam.dltTime + 1) );
    end
    if isempty(ptr)
        ptr = find(frames == (birth.time + birthNodeParam.dltTime - 1) );
    end
    if isempty(ptr) || (ic>1 && cellN==birth.cellN) % cell matched to itself if fluor peak beg in trajectory.
        test(ic) = Inf;
    else
        range = max(1, ptr-window):min(ptr+window, length(frames));
        test(ic) = min( cells(cellN).data(range, 3) ./ cells(cellN).fdata(range, 1) );
    end
end

[min_test, imin] = min(test(2:end));  %max over all sibs
if isempty(imin) || min_test==Inf
    fprintf(1, '  filterBirthsSibs rejected all sibs for birth=, sibs=\n');
        birth
    for ss = reshape(sibs, 1, {})
        ss
    end
    birth.sibling = [];
    return
else
    birth.sibling = sibs(imin);
end

if birthNodeParam.verbose > 1
    other_sibs = sibs;
    other_sibs(imin) = [];
    other_cells = [other_sibs.cellN];
    other_test = test(2:end);
    other_test(imin) = [];
    fprintf(1, '  for birth, cell,time,test= %d %d %d chose sib cell,test= %d %d over sib cells/test= %d %d\n',...
        birth.cellN, birth.time, test(1), sibs(imin).cellN, test(imin+1), other_cells(1), other_test(1) );
    if length(other_cells) >= 2
        [other_cells(2:end),  other_test(2:end) ]
    end
end
return

function [all_cells, cells_and_sibs, births] = unique_births(births, dltTime)
% Input births that have one and only one sibling.  
% Find sibling cells that are also birth cells.
% When the 'birth time' assoc with sibling cell ~ birth time of its nominal
% parent, add the birth with smallest fluor peak to the duplicate list.
%
all_cells = [births.cellN];
for ii = 1:length(births)
    cN_sib = births(ii).sibling.cellN;
    jj = find(cN_sib == all_cells);
    if isempty(jj) % one cell can have > 1 birth and thus not all sibs are in all_cells
        continue
    end
    for jj1 = reshape(jj, 1, [])  % a given sib cell can have multiple fluor peaks and hence mulitple births
        if( abs( births(ii).time - births(jj1).time ) <= dltTime )
            if births(ii).lmaxF > births(jj1).lmaxF
                births(jj1).duplicate = 1;
            else
                births(ii).duplicate = 1;
            end
        end
    end
end
% get unique cells after using lists to assign dupl
all_sibs = [births.sibling];
all_sibs = [all_sibs.cellN];
cells_and_sibs = intersect(all_cells, all_sibs);
all_cells = unique([all_cells, all_sibs] );

function diagnostic_plot(births, type)
% to display data about subsets of the births struct

figure
% axes( 'PlotBoxAspectRatio', [3,1,1]);  % unclear how to use.
subplot(1,3,1), hist([births.lmaxF], 20);
title(['max nuc fluor at peaks ', type] );
subplot(1,3,2), plot([births.lminD], [births.lmaxF], 'o');
title(['maxFluor vs minDiffCst ', type] );
subplot(1,3,3), plot([births.width], [births.lmaxF], 'o');
title(['maxFluor vs peak width ', type] );



