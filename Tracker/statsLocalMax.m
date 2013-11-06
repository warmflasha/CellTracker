function statsLocalMax(cells)
% 
% Evolving script to dump various stats based on the data computed in
% addLocalMax2Cells. Defns of what data is being processed are set in that
% routine.
%
%   cells3 = addLocalMax2Cells(cells2);  (calls ddata2lmaxStruct for each cell
%   statsLocalMax(cells);
%
% The struct array lmax() defined in ddata2lmaxStruct() with the fields. 
%
%   frame   time (int frame) of local max
%   width_half   width based on half max
%   width_min    width based on diff of flanking local mins
%   max     value of data at max
%   min1    value of left local min
%   min2    value of right local min
%   max2    average of data at min, each side of max, OR max of min's
%           to disfavor shoulders in data
%   jump    max/max(0, max2) - 1
%
% Each element of lmax struct represents one local max. The algorithm for 
% finding local max is defined in ddata2lmaxStruct().) This data is packaged
% with cells3(ii).lmaxcell{ntype} and then rearranged here into one long struct
% array called all_lmax(1..ntype) for each 'ntype' by
%
%   all_lmax = repackage_lmax(cells, frac_select)
%
% The defn of ntype = [1,2,3,4] currently is [nuc marker, smad nuc, smad cyto,
% ratio smad nuc/cyto] and is set in addLocalMax2Cells().
%
% Various plotting routines use one form or other of the lmax data and pluck out
% suitable fields. Sometimes we use extractGaussianFromHist() to find just the
% most signficant data points.
%
% TODO need routine to fit half gaussian or gamma distribution to data and
% select tails, for the jump data at maxs its not gaussian

global userParam
userParam.verbose = 1;

global plotParam
plotParam.minframe = 1;
plotParam.maxframe = 100;

% parameter to cutoff histogram of local max fluor based on a gaussian
% approx to low values. Assuming fluor in relative units, First bin where counts >
% gaussian_fit/(1-fracFluorSelect) is the cutoff. 
% the value chosen will depend on the method for computing the local max.
frac_select = 0.9;

% collect together all the lmax struct arrays of given type for all cells.
% meaning of each type defined in addLocalMax2Cells, currently is 
%     nucmarker, smad_nuc, smad_cyto, smad_nuc/smad_cyto
all_lmax = repackage_lmax(cells);

% histograms of the jump's for each type, dropping small values of jump.
% Adds cutoff value to each all_lmax, for later signficance testing.
all_lmax = hist_jump_lmax(all_lmax, frac_select);

% plot the number of good cells vs frame
cnts = good_cells(cells, 1);

% plot vs time lmax.field, can filter lmax via limits on any field before
% passing the lmax struct array to routine.
% llmax = all_lmax(4).lmax
% dd = [llmax.max];
% take = 0.3<dd & dd<2;
% plot_field(llmax(take), 'max', '')

plot_field(all_lmax(4).lmax, 'max', 'nuc/cyto smad');

return

function all_lmax = repackage_lmax(cells)
% take each type of lmax for each cell and return as struct array with all
% the data for each type as one long array.
%   all_lmax() is the struct array (elements = #data types) with fields
%   lmax    the lmax struct array for all cells
%   cutoff  defined elsewhere, lmax.max values > cutoff are significant.
%
good = find([cells.good], 1, 'first');
ntype = length(cells(good).lmaxcell);
all_lmax = struct('lmax',{}, 'cutoff',{});

all = [cells(logical([cells.good]) ).lmaxcell];
for it = 1:ntype
    temp = all(it:ntype:end);
    lmax = temp{1};
    for i = 2:length(temp)
        lmax = [lmax, temp{i}];
    end
    %all_lmax(it).cutoff = cutoff_lmax_data([lmax.jump], frac_select);
    all_lmax(it).lmax = lmax;
end

function all_lmax = hist_jump_lmax(all_lmax, frac_select)
% histogram jumps for all the data types represented in all_lmax. Remove
% the obviously low values to get better gaussian approx to peak of histo.
% add a cutoff value to all_lmax, for later filtering of data

minjump = 0.2;
verbose = 1;   % plot histograms
for it = 1:length(all_lmax)
    data = [all_lmax(it).lmax.jump];
    data = data(data > minjump);
    data = min(data, 2.);  % don't discard these points

    [cnts, bins] = hist(data, 80);
    ifit = extractFitFromHist(cnts, frac_select, 'gaussian0');
    cutoff = bins(max(1, ifit));
    all_pts = length(data);
    %over_cut = sum(cnts((ifit+1):end));
    gtcutoff = sum(data >= cutoff);
    all_lmax(it).cutoff = cutoff;
    if verbose
        figure, bar(bins, cnts);
        tstring = sprintf('hist lmax(%d).jump, cutoff= %d. #pts= %d, #>cutoff= %d',it,cutoff,all_pts, gtcutoff);
        title(tstring);
    end
end

function [cutoff, gtcutoff] = cutoff_lmax_data(data, frac_select)
% for data that physically is mostly <=2, approx distribution and find
% tails, 
[cnts, bins] = hist(min(data,2), 80);
ifit = extractFitFromHist(cnts, frac_select, 'gaussian0');
cutoff = bins(max(1, ifit));
gtcutoff = sum(data >= cutoff);


%%%%%%%%%%%%%%%%% various plots %%%%%%%%%%%%%%%%%%%%%%
function plot_field(lmax, field, title_str)
% plot the average of 'field' vs time

global plotParam

nn = max([lmax.frame]);
cnts = zeros(1,nn);
pts  = zeros(1,nn);
for i = 1:length(lmax)
    ff = lmax(i).frame;
    cnts(ff) = lmax(i).(field);
    pts(ff) = pts(ff) + 1;
end
cnts = cnts ./ pts;

range = max(1, plotParam.minframe):min(nn, plotParam.maxframe);
figure 
subplot(1,2,1), plot(range, cnts(range), 'd');
title([title_str, ' average of lmax.', field,' vs frame']);
subplot(1,2,2), plot(range, pts(range), 'd');
title('counts of points');

function cnts = good_cells(cells, verbose)
% find number of good cells(frame) verbose=1 plot 
global plotParam

cnts = zeros(1,1000);
for nc = 1:length(cells)
    if ~cells(nc).good
        continue
    end
    cnts(cells(nc).onframes) = cnts(cells(nc).onframes) + 1;
end
ii = find(cnts>0, 1, 'last');
cnts((ii+1):end) = [];
if verbose
    range = max(1, plotParam.minframe):min(ii, plotParam.maxframe);
    figure, plot(range, cnts(range), 'd')
    title('number of good cells vs frame')
end

function time_scatter(cells, all_lmax)
% a scatter plot of times between two types of data eg nuc peaks and smad
% ratio peaks. To limit data, select just the more significant values of
% lmax.jump to plot. For each cell plot for each time1 closest time2 and
% conversely. Cells must have >=1 pt of each type to appear

global plotParam

types = [1,4];  % 1,4 is nuc peak and smad ratio
% set fraction cutoffs select the non gaussian tail of distributions with the
% nuc threshold set higher to approx the number of good cells born between first
% and last times considered
frac_cutoffs = [0.95, 0.6];
field = 'jump';
for jj = 1:2
    data = [all_lmax(types(jj)).lmax.(field)];
    ldata(jj) = length(data);
    [cutoff(jj), gtcutoff(jj)] = cutoff_lmax_data(data, frac_cutoffs(jj) );
end


time = zeros(2,0);  % collect pairs of times for scatter plot.
cnts1=0; cnts2=0;   % number of local max of each type
for ii = 1:length(cells)
    if ~cells(ii).good
        continue
    end
    for jj = 1:2     
        lmax = cells(ii).lmaxcell{types(jj)};
        take = [lmax.(field)] > cutoff(jj);
        lmax = lmax(take);
        frame{jj} = [lmax.frame];
    end
    if isempty(frame{1}) || isempty(frame{2})
        continue
    end
    
    cnts1 = cnts1 + length(frame{1});
    cnts2 = cnts2 + length(frame{2});
    all = sort([frame{1}-0.1, frame{2}+0.1]);
    for jj = 2:length(all)
        % if hit continguous frames from different lmax, record times/frame
        if mod(all(jj-1) - all(jj), 1) > 0.1
            if mod(all(jj-1),1) > 0.5
                time(1,end+1) = all(jj-1);
                time(2,end) = all(jj);
            else
                time(1,end+1) = all(jj);
                time(2,end) = all(jj-1);
            end
        end
    end
end
time = round(time);  % get rid of +-0.1;
time = max(time, plotParam.minframe);
time = min(time, plotParam.maxframe);
for i = 1:size(time,2)
    if sum(time(:,i)==plotParam.maxframe) == 2
        time(:,i) = [0;0];
    end
    if sum(time(:,i)==plotParam.minframe) == 2
        time(:,i) = [0;0];
    end
end
take = time(1,:)>0;
time = time(:,take);

fprintf(1, 'time scatter plot, types= %d %d, all lmax pts= %d %d, pts= %d %d, gt cutoff= %d %d, selected on field= %s\n',...
    types, ldata, gtcutoff, cutoff, field);

figure, plot(time(1,:), time(2,:), 'd');
title(['frames lmax, data types= ', num2str(types), ' cnts= ', num2str([cnts1, cnts2]) ]);
xlabel(['data type= ', num2str(types(1)) ]);
ylabel(['data type= ', num2str(types(2)) ]);

return

function scatter_next_time(cells, all_lmax)
% for one type of data, plot below the diagonal, t1 > t2 for all successive
% times (frames)

global plotParam

type = 4;  % 1,4 is nuc peak and smad ratio
% set fraction cutoffs select the non gaussian tail of distributions with the
% nuc threshold set higher to approx the number of good cells born between first
% and last times considered
frac_cutoffs = 0.4;
field = 'jump';
data = [all_lmax(type).lmax.(field)];
ldata = length(data);
[cutoff, gtcutoff] = cutoff_lmax_data(data, frac_cutoffs);

time = zeros(2,0);  % collect pairs of times for scatter plot.
ptr = 0;
for ii = 1:length(cells)
    if ~cells(ii).good
        continue
    end    
    lmax = cells(ii).lmaxcell{type};
    take = [lmax.(field)] > cutoff;
    lmax = lmax(take);
    frames = [lmax.frame];
    for jj = 2:length(frames)
        ptr = ptr + 1;
        time(1,ptr) = frames(jj);
        time(2,ptr) = frames(jj-1);
    end
end

time = time + 0.5*(rand(size(time)) - 0.5);  % to see multiple symbols at same times
plot(time(1,:), time(2,:), '.')
title(['succesive times, data type= ', num2str(type), ' pts= ', num2str(ptr), ' gt cutoff= ', num2str(cutoff)] );
    