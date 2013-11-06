function selected_births = findStemCellBirthNodes( cells, peaks )
%
%   selected_births = findBirthNodes( cells, peaks )
%
% Algorithm:
%
%   Use the spline smoothed data to find local min in averaged nuclear
%       fluor. Use a decent smoothing spline param, to eliminate minor max/min
%       Eliminate local for which the average nuc fluor is well correl with
%       smad fluor, which generally implies imaging problems. 
%
%   For each local min, look in within neighboring frames (incl beyond the
%       end of the trajectory of the cell in question if the min falls on
%       last frame of trajectory). Locate siblings to the parent cell by
%       finding a pair of nuclei in peaks array, that are close to parent
%       and close to each other after reflecting one of them in position of
%       parent.  
%
%   Function dst_limits() has distance cutoffs, sib-parent and sib-sib.
%       They are computed as a linear function of the median and std of
%       nearest neighbor distances at each time. Can fiddle to get more or
%       fewer sibs.
%
%   There is no further filtering of sibs, based on their time histories,
%       we do not insist that one of sibs should be labeled same as parent
%       and other sib should be new cell.
%
%   Bugs: if the spline smoothing parameter does not filter out jitter in
%       nuc fluor vs time, then will find minor neighboring local max and
%       will reject local min, since not enough change vs local max.
%       'time' everywhere refers to frame number 

global birthNodeParam

% value 1 gets histograms of distributions that are cutoff, 2 prints all
% births.
birthNodeParam.verbose = 2;

% compute min time between births on a single cell trajectory in frame units
% Not used yet, but can limit time between putative births.
ncell0 = sum( peaks{1}(:,4)>0 );
ncell1 = sum( peaks{end-1}(:,4)>0 );
total_time = length(peaks);
tdiv0 = total_time/abs(log2(ncell1/ncell0));   % units of frames
birthNodeParam.minDivTime = min(36, tdiv0/2);  % assuming 20min frames

% select local min with property (local-max-fluor - local-min-fluor)/local-min 
% > fracValidMin.
% Reject minima whose normalized correl with smad fluor is > correlCoef
birthNodeParam.fracValidMin = 0.5;
birthNodeParam.correlCoef   = 0.75;

% There are cutoff lengths in dst_limits() defined adaptively interms of NN
% distances, and printed under verbose>=1 option.

% end of parameter definitions

% For each cell create struct, births(ncell) with fields 
%   lmin    (local min) a struct array for each births(ncell) with fields
%       x, y    usual positions...
%       time    the frame number of local min
%       fmin    the nuc fluor at min
%       fmax    average nuc fluor at two surrounding local max
%       width   half the difference in frame numbers of surrounding l-max
%       at_end  1 if there is no max following the local min, 0 otherwise.
%       sibs    struct with fields (sibs=[] if none found)
%           dst     distance sib1 + sib2 - 2*r-parent ie dst after reflecting one sib
%                   around position of parent
%           time    frame number when best sib pair found
%           sib1    the line of data from peaks for this cell at frame=time
%                   includes cells with numbers -1
%           sib2    ibid for other sib
%
%   ncell   cell number. Same as births(ncell), but allows one to use [births.ncell]
%           to get list of cells with at least one valid local min
%
% births(ncell) = [] if no valid local min, NB length(struct()) ==1 ie 
%
[births, stats] = local_min_struct(cells);

% record stats of local min
fprintf(1, 'findStemCellBirthNodes: found %d local min nuc-fluor with frac change > %6.3f among %d good cells\n',...
    stats.allmin, birthNodeParam.fracValidMin, sum([cells.good]) );
fprintf(1,'    removed %d l-min based on area change, %d based on correl smad-fluor, leaving %d good l-min\n',...
    stats.badarea, stats.badcorrel, stats.goodmin );

% search for possible sibs and add sibs struct to births().lmin
births = find_sibs(cells, peaks, births);

% 
% % define other param to be used in selecting plausible birth events.
% birthNodeParam.diffMean = mean(all_diffusion);
% birthNodeParam.diffStd = std(all_diffusion);
% 
% fprintf(1, '  mean, std of computed diffusion cst= %d %d\n', birthNodeParam.diffMean, birthNodeParam.diffStd);
% 
% selected_births = cellsSplined2BirthStruct(splined);
% 
% % define a new field for births struct, its a struct array for each sib
% selected_births(1).sibling = struct('cellN',{}, 'time',{}, 'dst',{});
% [selected_births, birth_data] = match_births2births(selected_births, cells);
% selected_births = match_cell_traj2births(selected_births, birth_data, cells);
% 
% % final births array has 1 and only 1 sib for each birth.
% selected_births = filterBirthsSibs(selected_births, cells);

return

%%%%%%%%%%%%%% end of main %%%%%%%%%%%%%%%
function births = find_sibs(cells, peaks, births)
%
% check for displacements of 2 sibs around position of parent at min of nuc
% fluor. Search peaks
% Adds new field = 'sibs' to each entry of births.lmin with the fields
%   sibs = struct('dst',{}, 'time',{}, 'sib1',{}, 'sib2',{})
%
% TODO 
% change struct.time struct.frame

global birthNodeParam

range = [-1,3];  % look for sibs over this range of times around min fluor
% putative sibs must be within distance == max_parent_sib from parent
% max_parent_sib = mean-nn-dst + std_parent_sib * std-nn-dst
% see function dst_limits() 

% sample the times in peaks{}, compute mean std of nn distance. 
% Use to put cutoff on allowed dst parent-sib
nn_stats = nn_dst(peaks);  
if birthNodeParam.verbose
    fprintf(1, '    median std NN dist: first frame= %6.3f %6.3f, last frame= %6.3f %6.3f\n',...
        nn_stats(1).median, nn_stats(1).std,  nn_stats(end).median, nn_stats(end).std );
end

all_lmin = 0;   % counts number of local min
iptr = 0; % counts elements of sib_stats
% for diagnostics, struct with fields 
%   dst1_2 = dist(sib1 - reflection sib2).
%   dst_r0 = average distance (parent - sib)
%   at_end = 1 if no max following the local min
sib_stats = struct('dst1_2',{}, 'dst_r0',{}, 'at_end',{}); % for debugging purposes

for nc = 1:length(cells)
    if ~cells(nc).good
        continue
    end
    if nc > length(births) || isempty(births(nc).ncell) 
        continue
    end
    
    lmin = births(nc).lmin;
    all_lmin = all_lmin + length(lmin);
    frames = cells(nc).onframes;
    % add sibs field to each local min in lmin struct.
    for ll = 1:length(lmin)
        % unused option to use frame where jump in position rather than lmin
%         time1 = max(lmin(ll).time + range(1), frames(1));
%         time2 = min(lmin(ll).time + range(2), frames(end));
%         i1 = find(time1 == frames, 1);
%         i2 = find(time2 == frames, 1);
%         % express range for jump in row indices of xy array.. possibly
%         % reset plausible division time
% 
%         [jump, ii, diff_dst] = detect_jump(cells(nc).data(:, 1:2), [i1,i2]);
%         if ~isempty(jump)
%             fprintf(1, '\ncell= %d t-range= %d %d, max,median jump in pos= %d %d, at time= %d\n',...
%                 nc, time1, time1, jump, diff_dst, frames(ii));
%         end
        
        % loop over range of times around min nuc fluor and find best pair
        % of sibs related by reflection in the position of parent, r0
        times = lmin(ll).time + range;
        times = max(times, 1);
        times = min(times, length(peaks));
        r0 = [lmin(ll).x,lmin(ll).y];
        
        % add the sibs structure to lmin struct array, listing the local
        % min in nuc fluor.
        sibs = struct('dst',{}, 'time',{}, 'sib1',{}, 'sib2',{});
        [max_parent_sib, max_sib_sib] = dst_limits(nn_stats, times(1));
        
        % loop over range of times and find best pair of sibs by reflection
        for tt = times(1):times(2)
            jj = tt - times(1) + 1;         
            [sibs(jj).dst, sibs(jj).sib1, sibs(jj).sib2] = best_sibs(r0, peaks{tt}, max_parent_sib);
            sibs(jj).time = tt;
        end
        [dst, jj] = min([sibs.dst]);
        % [max_sib_sib, max_parent_sib]
        if dst < max_sib_sib  
            lmin(ll).sibs = sibs(jj);
        else
            lmin(ll).sibs = [];
        end
        
        if birthNodeParam.verbose>1 && ~isempty(lmin(ll).sibs)  
            sibs2p = lmin(ll).sibs;
            fprintf(1, '\nfound sibs: parent cell= %d, frames %d-%d min-fluor t= %d, x,y= %d %d \n',...
                nc, frames(1), frames(end), lmin(ll).time, lmin(ll).x,lmin(ll).y ); 
            dst_r0 = dst_parent_sib(r0, sibs2p);
            fprintf(1, 'sib time= %d. x,y,sib1= %d %d %d, ..sib2= %d %d %d, dst(1-refl 2),(p-sib)= %4.2f %4.2f\n',...
                sibs2p.time, sibs2p.sib1(1:2),sibs2p.sib1(end), sibs2p.sib2(1:2),sibs2p.sib2(end), sibs2p.dst, dst_r0);
            iptr = iptr + 1;
            sib_stats(iptr).dst1_2 = sibs2p.dst;
            sib_stats(iptr).dst_r0 = dst_r0;
            sib_stats(iptr).at_end = lmin(ll).at_end;
        end
    end
    births(nc).lmin = lmin;
end

if birthNodeParam.verbose
    figure, hist([sib_stats.dst1_2]);
    title('distance sib1 - refl sib2 relative to parent');
    figure, hist([sib_stats.dst_r0]);
    title('distance parent-sib');
    fprintf(1, '\nFound %d sib pairs for %d local min. %d at end of trajectory. Subject to cutoffs on dst\n',...
        length(sib_stats), all_lmin, sum([sib_stats.at_end]) );
    [ps1, ss1] = dst_limits(nn_stats, 1);
    [psn, ssn] = dst_limits(nn_stats, length(peaks));
    fprintf(1, '    for 1st time dst(parent-sib) (sib-sib)= %4.2f %4.2f, last time (..)= %4.2f %4.2f\n',...
        ps1, ss1, psn, ssn);
end
return

function dst = dst_parent_sib(r0, sibs)
dst = (norm(r0 - sibs.sib1(1:2)) + norm(r0 - sibs.sib2(1:2)) )/2;

function [max_parent_sib, max_sib_sib] = dst_limits(nn_stats, time)
% compute the max allowed distances, parent-sib and sib-sib
std_parent_sib = 0;
[xxx, it] = min( abs([nn_stats.time] - time) );
max_parent_sib = nn_stats(it).median + std_parent_sib*nn_stats(it).std;
max_sib_sib    = nn_stats(it).median/2;

function [dst12, sib1, sib2] = best_sibs(r0, peaks1t, max_dst)
%
% for parent at r0, find pair of nuclei that are within max_dst of r0 and
% their positions under inversion in r0 are as close as possible.
%
% return smallest distance between pair of nuclei after reflecting one,
% sib1,2 = two rows of peaks array of nuclei related by reflection.
% If no pairs of nuclei within max_dst return dst12 = Inf.

dst12 = Inf;  sib1 = [];   sib2 = [];
xdst = abs(peaks1t(:,1) - r0(1));
select = xdst<max_dst;
peaks1t = peaks1t(select, :);
if size(peaks1t,1) < 2
    return
end
% xdst(~select) = []; 

ydst = abs(peaks1t(:,2) - r0(2));
select = ydst>=max_dst;
ydst(select) = [];
if length(ydst) < 2
    return
end

% down weight pairs of putative sibs far from r0 vs closer ones.
xy = peaks1t(~select, 1:2);
xy = xy - ones(size(xy,1),1) * r0;
xynorm = sqrt( xy(:,1).^2 + xy(:,2).^2);
mid_dst = median(xynorm);
xynorm(xynorm > max_dst) = Inf; % enforce distance constraint
dst = ipdm(xy, -xy);  
for i = 1:length(dst)
    for j = 1:length(dst)
        dst(i,j) = dst(i,j)*(1 + (xynorm(i) + xynorm(j))/mid_dst );
    end
    dst(i,i) = Inf;  % omit case 2 sibs identical
end
sort_dst = sort(dst,2);
[dst12, idx] = sort(sort_dst(:,1));

% convert to indices of peaks1t
csum = cumsum(~select);
i = find(idx(1)==csum,1);
j = find(idx(2)==csum,1);
sib1 = peaks1t(i,:);
sib2 = peaks1t(j,:);
% compute distance between reflection of sib2-r0 and sib1-r0. Should use
% metric measuring degree sib1-r0 is refl of sib2-r0, maybe dimensionless
rr = sib1(1:2) + sib2(1:2) - 2*r0;
dst12 = sqrt(rr * rr');
return

function nn_stats = nn_dst(peaks)
% find mean, std of nearest neighbor distances, drop obvious cells not
% connected with main cluster. Sample the frames and return struct.

nn_stats = struct('time',{}, 'median',{}, 'std',{});

iptr = 0;
for tt = 1:10:length(peaks)    
    distances=ipdm(peaks{tt}(:,1:2));
    sort_distances = sort(distances,2);
    dst = sort_distances(:,2);
    meand = median(dst);
    stdd  = std(dst);
    dst(dst>meand + 2*stdd) = [];
    iptr = iptr + 1;
    nn_stats(iptr).time = tt;
    nn_stats(iptr).median = median(dst);
    nn_stats(iptr).std  = std(dst);
end
return


function [ldata, stats] = local_min_struct(cells)
% return struct array, indexed by cell number describing
% the local minima that pass various filters based on dip in (avr) nuclear
% fluorescence, area, time of event on time trajectory..  
% SEE LOOP BELOW FOR DETAILS THEY CHANGE TOO MUCH TO COPY HEER
%
% ldata struct array has fields
%   lmin    (local min) a struct with fields
%       x, y    usual positions...
%       time    the frame number of local min
%       fmin    the nuc fluor at min
%       fmax    average nuc fluor at two surrounding local max
%       width   half the difference in frame numbers of surrounding l-max
%       at_end  1 if there is no max following the local min, 0 otherwise.
%
%   ncell   cell number. Same as index, but allows one to use [ldata.ncell]
%           to get list of cells with at least one valid local min
%
% ldata(ncell) = [] if no valid local min, NB length(struct()) ==1 ie 
%
% stats collects counts of what is filtered by what test for printing later
%

global birthNodeParam

ldata = struct('lmin',{}, 'ncell',{});
stats = struct('allmin', 0, 'badarea',0', 'badcorrel',0', 'goodmin',0 );
for ncell = 1:length(cells)
    if ~cells(ncell).good
        ldata(ncell).lmin = struct();
        continue
    end
    xx = cells(ncell).onframes;
    nuc_fluor = cells(ncell).sdata(:,1);
    smad_nuc  = cells(ncell).sdata(:,2);
    % return the indices of extrema and logical 0,1 vector for the max, 
    [idx, isamax] = extremaEDS(nuc_fluor);
    
    if isamax(1)
        start = 2;
    else
        start = 3;  % skip beginning local min
    end
    
    iptr = 0;
    lmin = struct();
    % run over all local min
    for ii = start:2:length(idx)
        fmin = nuc_fluor(idx(ii));
        im1 = idx(ii-1);  % indices into data arrays of neighboring loc max
        ip1 = ii+1;
        % in case no following max
        if(ip1 > length(idx));
            ip1 = [];
        else
            ip1 = idx(ip1);
        end
        
        % only pass local min that differ via ratio test from bracketing
        % local max values. Check both local max, want to remove case where
        % data like 1 1 1 2 1 1.1 1.1  ie where isolated local max defines
        % a one sided large drop. Are not filtering middle min in 1112 1 2111
        if isempty(ip1)  
            fmxx = nuc_fluor(im1)*ones(1,2);
            if fmxx(1)/fmin -1 < birthNodeParam.fracValidMin
                continue
            end
        else
            fmxx = sort([nuc_fluor(im1), nuc_fluor(ip1)]);
            %%[fmxx, fmin, ii]
            if fmxx(1)/fmin -1 < birthNodeParam.fracValidMin/2 || fmxx(2)/fmin -1 < birthNodeParam.fracValidMin
                continue
            end
        end

        stats.allmin = stats.allmin + 1;
        
%         % check changes in area, if min-area - max-area > frac*max then the
%         % drop we computed in area averaged nuc-fluor could all be
%         % explained by fixed total fluor and incr in nuc-area. Thus skip
%         % If change in area with fixed total nuc fluor
%         amin = cells(ncell).data(idx(ii),3);     
%         area_mx = (cells(ncell).data(im1,3) + cells(ncell).data(ip1,3))/2;
%         if amin/area_mx - 1 > birthNodeParam.fracValidMin
%             stats.badarea = stats.badarea + 1;
%             if verbose
%                 plot(xx',cells(ncell).data(:,3),'r', xx',nuc_fluor,'g', xx',smad_nuc,'b');
%                 legend('area', 'nuc', 'smad-nuc');
%                 title(['cell#= ', num2str(ncell), ' frame= ', num2str(xx(idx(ii))), ' rejected by area']);
%                 xlabel('frame number');
%             end
%             continue
%         end
        
        % check correl with smad fluor, if high then local min nucl-fluor
        % due to imaging problem. Do not test min at end point
        if ~isempty(ip1) && xx(ip1)-xx(im1) > 3
            diff1 = diff(nuc_fluor(im1:ip1));
            diff2 = diff(smad_nuc(im1:ip1));
            correl = corrcoef([diff1, diff2]);  % normalized correl of 2 cols
            if correl(1,2) > birthNodeParam.correlCoef
                stats.badcorrel = stats.badcorrel + 1;
                continue
            end
        end
        
        % local min passes all tests
        iptr = iptr + 1;
        time = xx(idx(ii));
        lmin(iptr).x = cells(ncell).data(idx(ii),1);
        lmin(iptr).y = cells(ncell).data(idx(ii),2);
        lmin(iptr).time = time;
        lmin(iptr).width = abs(xx(im1)-time);
        if ~isempty(ip1)
            lmin(iptr).width = (lmin(iptr).width + abs(xx(ip1)-time))/2;
        end
        lmin(iptr).fmin = fmin;
        lmin(iptr).fmax = sum(fmxx)/2;
        if isempty(ip1)
            lmin(iptr).at_end = 1;
        else
            lmin(iptr).at_end = 0;
        end
        stats.goodmin = stats.goodmin + 1;
    end
    ldata(ncell).lmin = lmin;
    if ~isempty(lmin) && isfield(lmin, 'time')  % aid to picking out cells with good min with [ldata.ncell]
        ldata(ncell).ncell = ncell;
    else
        ldata(ncell) = [];  % NB can not initialize this way since do.. complains about growing array
    end
end
        
function [rows, cols, dsts] = compute_allowed_dst(data1, data2, max_dst)
%
% Interface to the ipdm routine that cleans up output. 
%   Data1,2 are xy coordindates arranged as 2 cols, 
%   max_dst = max allowed pairwise distance
%   data2 = [] compute data1-data1 distance and eliminate redundancies
%   output is an array of rows for data1 that are matched to 'cols' (==rows) of data2
%   with a distance = dsts
%

if isempty(data2)
    dst = ipdm(data1(:, 1:2), 'Result', 'Structure', 'Subset', 'Maximum', 'Limit', max_dst);
else
    dst = ipdm(data1(:, 1:2), data2(:, 1:2), 'Result', 'Structure', 'Subset', 'Maximum', 'Limit', max_dst);
end

dsts = dst.distance;
rows = dst.rowindex;
cols = dst.columnindex;

if isempty(data2)
    self = (cols <= rows);
else
    self = (dsts == 0);
end

dsts(self) = [];
rows(self) = [];
cols(self) = [];

[rows, permu] = sort(rows);
cols = cols(permu);
dsts = dsts(permu);  % guaranteed to be <= Limit value

return
    
function [jump, j, median_dst] = detect_jump(xy, range)
% compute typical dst moved per time from the whole cell trajectory and
% then look over indices in range for a anomalously large jump.
% Return value of jump or [] if nothing large enough found and 
% j = index in input xy array corresponding to max jump.
%
% NOT USED CURRENTLY

xy = diff(xy);
dst = sqrt( xy(:,1).^2 + xy(:,2).^2 );
range = range -1;  % correct numbering for diff;
range = max(range, 1);
range = min(range, length(dst));
[dmax, j] = max(dst(range));
j = j+range(1);    % add 1 to compensate for diff(xy) shrinking xy by 1.
median_dst = median(dst);
cutoff = median_dst + std(dst);

jump = dmax;
% if dmax > cutoff
%     jump = dmax;
% else
%     jump = [];
% end
        
