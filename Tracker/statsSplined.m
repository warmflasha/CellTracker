function statsSplined(splined)

% The scatter plots of fluor and diff give impression of where births are.
%
% To select plausible divisions should use width of fluor peaks as well as
% fractional jump in max vs max2. Its just as good to define diffusion as
% difference between times with no splines, want low diffusion in absolute 
% terms, or relative to population histogram. and also want narrow fluor peak.
% its not clear a simple convolution kernal to get second deriv of fluor
% would not work as well as our splines. Need locate min neg and then
% adjacent max pos to define peak.

%lmin_diff = struct('time',{}, 'width',{}, 'min',{}, 'min2',{}, 'jump',{});
%lmax = struct('time',{}, 'width',{}, 'max',{}, 'max2',{}, 'jump',{});

global birthNodeParam

[fluor_flat, diff_flat] = flatten_splined(splined);

widthF = [fluor_flat.width];
heightF = [fluor_flat.jump];
figure, plot(widthF, heightF, 'o');
title('jump in fluor to max, vs width half max');

fracHeight = heightF ./ [fluor_flat.max2];
figure, plot(widthF, fracHeight, 'o');
title('fractional height fluor peak vs width half max');

[cnts, bins] = hist(min(fracHeight, 0.5), 40);
figure, bar(bins, cnts);
ifit = extractGaussianFromHist(cnts, 0.5);
title(['fractional height fluor peak, last bin incl>0.5, ifit (<= gaussian)', num2str(ifit)] );

widthD = [diff_flat.width];
heightD = [diff_flat.jump];
figure, plot(widthD, heightD, 'o');
title('jump in diff cst vs width half max');

figure, hist( [diff_flat.min], 20);
title('diff cst at all local min ');

[sorted_births, all_births] = cellsSplined2BirthStruct(splined);
diff = [all_births.lminD];
fluor = [all_births.lmaxF];
figure, plot(diff, fluor, 'o');
title(['allBirths: frac fluor jump vs min diff within abs(time)<= ', num2str(birthNodeParam.dltTime)]);

return

function [fluor_flat, diff_flat] = flatten_splined(splined)
% create new struct array with fluor/diff-cst data with new field 
%   cellN   cell number as in splined(cellN)
% and eliminates all the [] entries

fluor_flat = [];
diff_flat = [];
for i = 1:length(splined)
    if ~isempty(splined(i).lmaxFluor)
        temp = splined(i).lmaxFluor;
        for j = 1:length(temp)
            temp(j).cellN = i;
        end
        fluor_flat = [fluor_flat, temp];
    end
    if ~isempty(splined(i).lminDiff)
        temp = splined(i).lminDiff;
        for j = 1:length(temp)
            temp(j).cellN = i;
        end
        diff_flat = [diff_flat, temp];
    end
end

