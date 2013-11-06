function selected_births = cellsSplined2BirthStruct(splined)
%
%   selected_births = cellsSplined2BirthStruct(splined)
%
% Take the cell splined data and find all peaks in nuc fluor that are near
% minima in diffusion cst. Find adaptive cutoff on nuc fluor peak and
% remove small peaks, and large diffusion constants.
%
% Return a births struct array with the following fields (code for this struct entirely
% in this routine). To put more conditions on selected_births, one can pull
% more information out of the splined(all cells) struct array and then use
% it in select_births(); (might use min nuc_area in addition to max fluor, but
% clearly correlated)
%
%   lmaxF   the fluor peak height as a multiple of the fluor near by.
%   lminD   the min diffusion constant (RMS change in position, 1 frame difference
%   cellN   the number of cell as input via the splined() struct array
%   time*   the times (frame #) of maxF, minD and average 
%

global birthNodeParam

all_births = make_births(splined, birthNodeParam.dltTime, birthNodeParam.minDivTime);

fprintf(1, '\ncellsSplined2BirthStruct: found %d possible births among %d cell trajectories\n', length(all_births), length(splined) );

% % for checking by hand top picks, do a sort.
% max_fluor = [all_births.lmaxF];
% [sorted, permu] = sort(max_fluor, 'descend');
% sorted_births = all_births(permu);

[selected_births, cutoffF, cutoffD, cells_after_cutoffF] = select_births(all_births);

fprintf(1, '  nuc fluor peak cutoff(jump/min)= %d allows %d births, then diffus cutoff= %d allows %d putative births\n',...
    cutoffF, cells_after_cutoffF, cutoffD, length(selected_births) );

return

%%%%%%% end of main %%%%%%%%%%%

function [sorted_births, cutoffF, cutoffD, cells_after_cutoffF] = select_births(births)
% program to order births from most plausible to least, and also drop
% unlikely births, based on fluor peak and min diffusion near by

global birthNodeParam

max_fluor = [births.lmaxF];
% to get histogram with controlled density of bins assume any fluor peak
% over 1. is definitely ok.. 
[cnts, bins] = hist( min(max_fluor, 1.), 80);
ifit = extractGaussianFromHist(cnts, birthNodeParam.fracFluorSelect);
if ifit < 1
    cutoffF = birthNodeParam.defaultFluorPeakCutoff;
else
    cutoffF = bins(ifit);
end
cutoffD = birthNodeParam.diffMean;

if birthNodeParam.verbose
    figure, bar(bins, cnts);
    title(['histogram of peak nuc fluor all putative births. Selected births are >= cutoff= ', num2str(cutoffF), ' and diffusion < ', num2str(cutoffD)]);
end

[sorted, permu] = sort(max_fluor, 'descend');
cells_after_cutoffF = find(sorted < cutoffF, 1, 'first');
sorted_births = births(permu);
if isempty(cells_after_cutoffF)
    fprintf(1, 'WARNING bad nuc peak fluor cutoff in cellsSplined2BirthStruct, all cells over cutoff??\n');
end

% now impose that the diffusion cst be < cutoff
sorted_births( (cells_after_cutoffF+1):end ) = [];
for i = 1:cells_after_cutoffF
    if sorted_births(i).lminD >= cutoffD
        sorted_births(i).cellN = -1;
    end
end
all_cellN = [sorted_births.cellN];
sorted_births( all_cellN < 0 ) = [];
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function births = make_births(splined, dlt, min_div)
% look for peaks in fluor and diff cst data on same traj separted by times
% <= dlt (in int units).  Impose that births must be separated by at least
% min_div (frames). Take the largest jump if conflicts.
% lmax/min = struct('time',{}, 'width',{}, 'max',{}, 'max2',{}, 'jump',{});

global birthNodeParam
births = struct('lmaxF',{}, 'lminD',{}, 'cellN',{}, 'time',{}, 'timeD',{}, 'timeF',{}, 'width',{});

for is = 1:length(splined)
    fluor = splined(is).lmaxFluor;
    diff = splined(is).lminDiff;
    if ~isempty(fluor) && ~isempty(diff)
        timeF = [fluor.time];   % 1 row
        timeD = [diff.time];    % 1 col
        ptr = 0;
        births1cell = struct('lmaxF',{}, 'lminD',{}, 'cellN',{}, 'time',{}, 'timeD',{}, 'timeF',{}, 'width',{});
        for i = 1:length(timeF)
            for j = 1:length(timeD)
                if abs(timeF(i) - timeD(j)) > dlt
                    continue
                end
                ptr = ptr + 1;
                births1cell(ptr).lmaxF = (fluor(i).max - fluor(i).max2)/fluor(i).max2;
                births1cell(ptr).lminD = abs(diff(j).min);
                births1cell(ptr).cellN = is;
                births1cell(ptr).time = round((timeF(i) + timeD(j))/2 );
                births1cell(ptr).timeF = timeF(i);
                births1cell(ptr).timeD = timeD(j);
                births1cell(ptr).width = fluor.width;
            end
        end
        unique_births = unique_births(births1cell, min_div);
        births = [births, unique_births];
        if birthNodeParam.verbose > 1
            fprintf(1, 'cell= %d, found %d fluor lmax, %d diff lmin, %d all births, %d unique b\n',...
                is, length(timeF), length(timeD), length(births1cell), length(unique_births) );
        end
    end
end

return

function births = unique_births(births, min_div)
% elimiante multiple mins in diff assoc with same peak in fluor. 
% impose min division time, favoring the strongest peaks
% Input is all births for one cell

ii = 1;
while ii < length(births)
    if births(ii).lmaxF == births(ii+1).lmaxF
        if births(ii).lminD < births(ii+1).lminD
            births(ii+1) = [];
        else
            births(ii) = [];
        end
    else
        ii = ii + 1;
    end
end

if length(births) < 2 
    return
end
[maxFsort, permu] = sort([births.lmaxF], 'descend');
births = births(permu);
times = [births.time];

nb = length(births);
for i = 1:nb
    if(times(i) < 0)
        continue
    end
    for ii = (i+1):nb
        if abs(times(ii)-times(i)) < min_div
            times(ii) = -1;
        end
    end      
end

births(times<0) = [];
return
    
    

