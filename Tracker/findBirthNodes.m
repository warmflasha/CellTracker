function selected_births = findBirthNodes( cells, peaks )
%
%   selected_births = findBirthNodes( cells, peaks )
%
% Algorithm:
%   spline smooth the cell data for x, y, nuc_area, nuc_fluor
%   select putative birth events (eg nuc fluor peaks in cell trajectory) in
%       cellsSplined2BirthStruct(). Min spacing between putative births set
%       by birthNodeParam.minDivTime. A few data points required on both
%       sides of nuc fluor peak
%   for each birth find the closest potential sibling, looking first at other
%       birth events, and then cell trajectories that start near time of
%       birth. birthNodeParam.dltTime defines the time interval over which
%       one searches for sibs. A max distance of 2*dst2dummy is imposed on
%       the distance between sibs. (this is a bit large, but 1*dst2dummy
%       misses some real births)
%   filter the births struct to resolve multiple sibs and discard births
%       with no plausible sibs (in filterBirthsSibs() )

% The births struct has the following fields:
%
%   lmaxF   the fluor peak height as a multiple of the fluor near by.
%   lminD   the min diffusion constant (RMS change in position, 1 frame difference
%   cellN   the number of cell as in cells(cellN(umber))
%   time*   the times (frame #) of maxF, minD and average: timeF, timeD, time
%   width   the width of the fluor peak, (see spineCells4BirthPeaks for defn)
%   duplicate [0,1], true if the peak in nuc fluor is also a valid sibling
%   sibling     itself a struct with fields
%       cellN   cellnumber of sibling
%       time    time, either 1st frame of new cell, or 'time' of fluor peak
%               if matched to another birth, need not be birth.time
%       dst     distance between
%
%
% selected_births that are returned are all births with one and only one
% valid sibling. They are ordered by fractional magnitude of nuc fluor peak
% 1st being the most plausible.
%
% % From cells array determine the birth nodes struct with fields NOT DONE
% %   parent(node#, 1)    the parent of this node
% %   children(node#, 2)  the two children of this node
% %   frame(node#, 3)     the time/frame of node
% %   data(node#, ..)     data used to score division.
%
% Observations:
%   The filter on diffusion constant does not do much,
% peaks in nuc fluor for cells near boundaries generally bogus
% matching birth-birth rather than birth to beginning of cell traj will
% often find correct births that result from tracking errors (either
% primary, in processing peaks{} or from trajectory mergers. Include nuc
% fluor or area in cost fn to control this)
%
% Loose ends:
%   Need a clean way of getting a mask for the CCC based on green channel
% into this routine to eliminate nuc fluor peaks near boundaries
%   peaks{} input used only to compute growth rate
%
% global birthNodeParam has parameters for commuication among routines to find births,
% A few of these related to movement between frames
% determined in matchFramesEDS (and thus typically during runTrackerEDS). Generally tried to minimize parameters
% relating to thresholds on intensity, area etc by computing histograms
% and separating into gaussian part plus a tail.
%
% TODO
%   eliminate cells on boundaries using mask, and dst2Boundary(). Currently 
% these cells often lack plausible sibs and are killed that way.
%
%   add option to elimiate testing on min diffusion cst, need change
% cellsSplined2BirthStruct and other stuff. OR better just check that
% diffusion at the max fluor is small enough, since in a few cases no local
% min at fluor peak, but cell not moving/
%

global birthNodeParam

% value 1 gets histograms of distributions that are cutoff, 2 prints all
% births.
birthNodeParam.verbose = 1;

% max time in frames between max of nuc fluor and min of diffusion cst to
% define a birth. Also max time between birth(ie peak of fluor) and
% putative sib.
birthNodeParam.dltTime = 4;

% compute min time between births on a single cell trajectory in frame units
ncell0 = sum( peaks{1}(:,4)>0 );
ncell1 = sum( peaks{end-1}(:,4)>0 );
total_time = length(peaks);
tdiv0 = total_time/abs(log2(ncell1/ncell0))/2;
birthNodeParam.minDivTime = min(24, tdiv0);  %default assuming 15min frames

% param that defines the cutoff on the peaks in nuc fluor to qualify as
% birth.  Increase to .99 to be more stringent, ~0.75 are reasonable 
% see extractGaussianFromHist.m for the algorithm.
birthNodeParam.fracFluorSelect = 0.85;

% if the cutoff on the peaks in nuc fluor can not be found from the
% histogram using the fracFluorSelect parameter, use this default (only a problem if <~ 200 peaks)
birthNodeParam.defaultFluorPeakCutoff = 0.25;

% computed in matchFramesEDS as max allowed distance between nuclei for a
% match. Set here for debugging
if ~isfield(birthNodeParam, 'dst2dummy');
    birthNodeParam.dst2dummy = 30;
    fprintf(1, 'WARNING in findBirthNodes: birthNodeParam.dst2dummy not set by prior call to matchFramesEDS, using default= %d\n',...
        birthNodeParam.dst2dummy );
end

fprintf(1, '\nfindBirthNodes: for each cell trajectory find putative births based on nuc fluor peak and min diffusion.\n');
fprintf(1, '  Pair with other putative births or beginning of cell traj based on parameters..\n');
fprintf(1, '  max distance= %d, max frame difference= %d, min frames between divisions= %d (#cells matched(t=1)= %d, (t=%d)= %d\n',...
    birthNodeParam.dst2dummy, birthNodeParam.dltTime, birthNodeParam.minDivTime, ncell0, total_time, ncell1);

% end of parameter definitions

% compute smoothed data in time and locate peaks in each cell trajectory.
% splined() indexed by cellN and lists local max's fluor and other stuff
[splined, all_diffusion] = splineCells4BirthPeaks(cells);

% define other param to be used in selecting plausible birth events.
birthNodeParam.diffMean = mean(all_diffusion);
birthNodeParam.diffStd = std(all_diffusion);

fprintf(1, '  mean, std of computed diffusion cst= %d %d\n', birthNodeParam.diffMean, birthNodeParam.diffStd);

selected_births = cellsSplined2BirthStruct(splined);

% define a new field for births struct, its a struct array for each sib
selected_births(1).sibling = struct('cellN',{}, 'time',{}, 'dst',{});
[selected_births, birth_data] = match_births2births(selected_births, cells);
selected_births = match_cell_traj2births(selected_births, birth_data, cells);

% final births array has 1 and only 1 sib for each birth.
selected_births = filterBirthsSibs(selected_births, cells);

return

%%%%%%%%%%%%%% end of main %%%%%%%%%%%%%%%
function [births, data] = match_births2births(births, cells)
% 
% compute pairwise distances between all pairs of births and time diffs.
% Assume the births are sorted to place the most probable candidates first.
% NOTE siblings may not correspond to new cells, we are just matching
% putative births on cell trajectories as defined by nuc fluor peak and
% other criterion.
%
% Output
%   births  added new field siblings to the birth struct array
%   data    array(#birth, [x, y, nuc_area, birth_time]  for use in matching
%           cell traj.

global birthNodeParam

nb = length(births);
data = zeros(nb, 4);
for i = 1:nb
    tt = births(i).time;
    frame0 = cells(births(i).cellN).onframes(1) - 1;
    data(i, 1:3) = cells(births(i).cellN).data(tt - frame0, 1:3); %    
    data(i, 4) = tt;   % not used here, but consistency with other data()
end

[rows, cols, dsts] = compute_allowed_dst(data, [], 2*birthNodeParam.dst2dummy);
nd = length(rows);

ptr1 = 1;
while ptr1 <= nd
    row1 = rows(ptr1);
    ptr2 = find(rows == row1, 1, 'last');
    
    time1 = births(row1).time;
    time2 = [births( cols(ptr1:ptr2) ).time];
    [tmin, imin] = min(abs(time2 - time1) );
    sibling = cols(ptr1 + imin - 1);
    if tmin <= birthNodeParam.dltTime && (births(row1).cellN ~= births(sibling).cellN)
        if birthNodeParam.verbose > 1
            fprintf(1, 'birth# cell# time= %d %d %d distance= %d from birth# cell# time= %d %d %d\n',...
                row1, births(row1).cellN, time1, dsts(ptr1 + imin - 1), sibling, births(sibling).cellN, births(sibling).time);
        end
        sib_struct = struct('cellN', births(sibling).cellN, 'time', births(sibling).time, 'dst', dsts(ptr1 + imin - 1));
        births(row1).sibling = [births(row1).sibling, sib_struct];
        sib_struct = struct('cellN', births(row1).cellN, 'time', time1, 'dst', dsts(ptr1 + imin - 1));
        births(sibling).sibling = [births(sibling).sibling, sib_struct];
    end
    ptr1 = ptr2+1;
end

function births = match_cell_traj2births(births, birth_data, cells)
% 
% compute pairwise distances between all pairs of births and time diffs.
% Assume the births are sorted to place the most probable candidates first.
% NOTE siblings in this routine restricted to beginning of cell trajectories
%
% Output
%   births  adds siblings to the birth struct array

global birthNodeParam

nc = length(cells);
cell_data = zeros(nc, 4);
for i = 1:nc
    tt = cells(i).onframes(1);
    cell_data(i, 1:3) = cells(i).data(1, 1:3);
    cell_data(i, 4) = tt;
end

[rows, cols, dsts] = compute_allowed_dst(birth_data, cell_data, 2*birthNodeParam.dst2dummy);
nd = length(rows);

ptr1 = 1;
while ptr1 <= nd
    row1 = rows(ptr1);
    ptr2 = find(rows == row1, 1, 'last');

    time1 = births(row1).time;
    time2 = cell_data( cols(ptr1:ptr2), 4);
    [tmin, imin] = min(abs(time2 - time1) );
    sibling = cols(ptr1 + imin - 1);
    if tmin <= birthNodeParam.dltTime && (births(row1).cellN ~= sibling)
        if birthNodeParam.verbose > 1
            fprintf(1, 'birth# cell# time= %d %d %d distance= %d from cell# beg-time= %d %d\n',...
                row1, births(row1).cellN, time1, dsts(ptr1 + imin - 1), sibling, cell_data(sibling, 4) );
        end
        sib_struct = struct('cellN', sibling, 'time', cell_data(sibling, 4), 'dst', dsts(ptr1 + imin - 1));
        births(row1).sibling = [births(row1).sibling, sib_struct];
    end

    ptr1 = ptr2+1;
end

function [rows, cols, dsts] = compute_allowed_dst(data1, data2, max_dst)
%
% Interface to the ipdm routine that cleans up output. 
%   Data1,2 are xy coordindates arranged as 2 cols, 
%   max_dst = max allowed pairwise distance
%   data2 = [] compute data1-data1 distance and eliminate redundancies
%   output is an array of rows for data1 that are matched to cols of data2
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
    

