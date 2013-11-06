function [min_top, std_bot] = cellsTopBottom(peaks, verbose)
%
%   [min_top, std_bot] = cellsTopBottom(peaks, verbose)
%
% partition cells into top (out of focus, large, low intensity) and bottom
% in focus, (smaller more intense). The criterion used to partition
% top/bottom cells (ie hist area, or area/.fluor, must be consistent with what is used in
% matchFramesEDS.m and costMatrixEDS.m
% 
%   min_top     is cutoff: top cells>cutoff, bottom cells < this value
%   std_bot     the std of the bottom cells (in whatever variable used to
%               partition)
%

nbins = 40;
frac_cutoff = 0.75;
np = length(peaks);

area = []; fluor = [];
for ii = 1:np
    area = [area, reshape(peaks{ii}(:,3), 1, []) ];
    fluor = [fluor, reshape(peaks{ii}(:,5), 1, []) ];
end
data = test4TopCells(area, fluor, []);
[cnts, xbin] = hist(data, nbins);
icut = extractGaussianFromHist(cnts, frac_cutoff);
min_top = xbin(icut);
[xxx, rms] = mean_rms_cnts(cnts(1:(icut-1)) );
std_bot = sqrt(rms)*(xbin(2) - xbin(1));

if verbose
    figure, bar(xbin, cnts);
    title(['cellsTopBottom(): hist that defines cells>cutoff= ', num2str(min_top), ' as top, see test4TopCells.m']);
end

% check no secular trend/drift in test4TopCells data.
% average over 4 times and then divide std by 2 to get std per one frame
data = run_loop(1:4, peaks);
data = data(data<min_top);
mean0 = mean(data );
std0 = std(data );
data = run_loop((max(1,np-3)):np, peaks);
data = data(data<min_top);
mean1 = mean(data );
std1 = std(data );

if abs(mean0 - mean1) > min(std0, std1)/2
    fprintf(1, 'WARNING cellsTopBottom: detected temporal drift of mean fluor|area of putative bottom cells, means %d %d, std %d %d\n',...
        mean0, mean1, std0, std1 );
end
if verbose
    fprintf(1, '    Change in mean&std of data that selects bottom cells, first vs last frame= %d %d, %d %d check for drift!\n',...
        mean0, std0/2, mean1, std1/2 );
end

function data = run_loop(range, peaks)
% extract the topCells data for a range of frames in peaks

area = []; fluor = [];
for ii = range
    area = [area, reshape(peaks{ii}(:,3), 1, []) ];
    fluor = [fluor, reshape(peaks{ii}(:,5), 1, []) ];
end
data = test4TopCells(area, fluor, []);


function [mean, rms] = mean_rms_cnts(cnts)
% for counts in uniformily space histogram bins compute mean bin index and
% rms of bin index characterizing a gaussian fit to data

sumc(1:3) = 0;
for i = 1:length(cnts)
    sumc(1) = sumc(1) + cnts(i);
    sumc(2) = sumc(2) + i*cnts(i);
    sumc(3) = sumc(3) + i*i*cnts(i);
end
mean = sumc(2)/sumc(1);
rms = sumc(3)/sumc(1) - mean^2;

function diagnostic_plots(area, fluor)
% dirty plots to see what is happening

figure, plot(area, fluor, 'o');
title('fluor vs area scatter plot');
[cnts, xbin] = hist(area./fluor, 40);
figure, bar(xbin, cnts);
title('hist fluor/area');
nbin = 20;
[cntA, binA] = hist(area, nbin);
[cntF, binF] = hist(fluor, nbin);
dltA = binA(2)-binA(1);
dltF = binF(2)-binF(1);
iiA = floor( area/dltA );
iiA = min(iiA - min(iiA) + 1, nbin);  %round off can push 1 number over nbin
iiF = floor( fluor/dltF );
iiF = min(iiF - min(iiF) + 1, nbin);

density = zeros(nbin, nbin);
for n = 1:length(area)
    density(iiA(n), iiF(n)) = density(iiA(n), iiF(n)) + 1;
end
density
return