function trajectory = mainPeaks2Trajectories(peaks)
%
% take the peaks{} cell array with peaks{time} = xy_area(:,3), run AW MatchFrames() 
% to add 4th col onto peaks array with link to next cell in next frame, if necessary
% 
% Reformat the peaks{} data structure into a trajectory struct array.
% Then take all trajectories which end in a band of times and match, via
% minimimizing distance cost matrix, to traj with beginning times in a band
% This is done to remove marginal matches when a better one is available at
% a later time. The cost to match to a dummy cell is computed adaptively.
%
% There is a parameter to discard trajectories < min_length, and a param
% merge_gap parameter in mergeTrajectories() which defines the interval of
% traj ends and beg's that are grouped together. Merger for a traj ending
% at tend is allowed for any traj that begins in range [tend, tend+merge_gap]
% All numerical data is linearly interpolated when traj merger results in
% missing times.
% 
% An explicit boundary state is introduced, and the cost to go there is
% just the min distance. Currently 'boundary' is just limits of image, but
% could easily introduce actual image of CCC. However this state seems to
% minimally impact results.
%
% trajectory struct array is defined with fields:
%   beg     first time (int >=1 by defn)
%   end     last time
%   merge   row vector of [end, beg] times of trajectories merged or []
%   cells   list of (1,end-beg+1) cell numbers corresponding to x,y,area at given time
%   cells   = -1 for interpolated times, otherwise >0
%   x       list of end-beg+1 x positions copied from peaks{} or interpolated
%   y       ibid   NB all data row matrix, time==column number
%   area    nuclear area, copied from peaks or interpolated.
%   data    anything in cols 5:end of peaks{} organized as mtx(#data, times)
%
% TODO introduce size of img array into costMatrixEDS since needed to compute distances 
% to boundary. Currently set as userParam.sizeImg = [..] below, 
% could record in setUserParam*.m file

global userParam    % eventually may go to setUserParam fn, but this routine stand alone.

%%%%% params for cellTrackerEDS routines -> setUserParam*.m function.
%
% There is a first pass over the peaks{} array that does matching of adjacent
% frames following AW, using all his parameters. The peaks{} array is
% transformed into a trajectory struct array by stringing together cells
% matched between successive frames. These trajectories are them subject to
% further merger based on a new cost matrix that sets the cost of matching
% to dummy based on actual statistics of distance moved per frame, and
% introduces a boundary state for which cost of match is distance to bndry.
%   There are parameters to discard trajectories < min_length. Trajectory
% merger is done by considering a band of loose ends [time, time+mergeGap]
% and computing cost matrix between all of them and a equal size band of
% loose trajectory beginnings. Merger is allowed for t_end < t_beg - 1, in
% which case x,y,area data is interpolated.

% Taken from AW, used in MatchFrames(), L is cost to match cell to dummy, pair distances > L are assumed Inf
% userParam.L = 40; %% = 0.04 set for EDS synthetic data

%%%%%% end of userParam defns

verbose = userParam.verboseCellTrackerEDS;

ntimes = length(peaks);
% count number of cells X times present in data as crude measure of amount
% of data, and what gets lost along the way.
cell_times_in = size(peaks{1}, 1);
for nt = 2:ntimes
    cell_times_in = cell_times_in + size(peaks{nt}, 1);
end

fprintf(1, '\nmainPeaks2Trajectories: ');
% Use AW routines to match cells between successive frames, and add 4th col to
% peaks{}(:,4)
if (size(peaks{1},2)<4) || all(peaks{1}(:,4)<0) 
    for nt = 2:ntimes
        peaks = MatchFrames(peaks, nt);
    end
    % peaks_out = peaks; %% save peaks for later trials, add to output variables.
else
    fprintf(1, 'found + entries in peaks{1}(:,4) assume MatchFrames called for all times\n');
    % peaks_out = [];
end

trajectory0 = peaks2Trajectories(peaks);
% add new field to all elements
trajectory0(1).merge = [];

% impose min length on raw trajectories, keep small incase fragements merge.
min_traj = userParam.minTrajLen; 
len = [trajectory0.end] - [trajectory0.beg] + 1;
cnts = hist(len, max(len));
fprintf(1, 'number of trajectories len=1,2,..omitted %d %d %d %d %d %d %d %d %d %d %d', cnts(1:(min_traj-1)) );
fprintf(1, '\n');

trajectory0 = trajectory0( len >= min_traj );
len( (len<min_traj) ) = [];   % for stats on mean, median length,
fprintf(1, '  Pre merge: cellXtimes(input= %d, in traj >min= %d), #trajectories= %d, mean, median len= %d %d\n',...
    cell_times_in, cnt_cell_times(trajectory0), length(trajectory0), round(mean(len)), median(len) );

if verbose
    figure, histTrajTimes(trajectory0, ' pre-merger traj');
end

% may want to impose a longer min traj length on output traj??
trajectory = mergeTrajectories(trajectory0);

len = [trajectory.end] - [trajectory.beg] + 1;
fprintf(1, '  Post merger: cellXtimes= %d #trajectories= %d, mean, median len= %d %d\n', ...
    cnt_cell_times(trajectory), length(trajectory), round(mean(len)), median(len) );

if verbose
    figure, histTrajTimes(trajectory, ' merged traj');
end

% want also stats for # traj beginning at t=X and not near boundary and > some
% length.

verifyTrajectory(trajectory);

return

function verifyTrajectory(traj)
%
% extract various stats

% merge_with_intrp = 0;
% pts_intrp = 0;
% for i = 1:length(traj)
%     nocells = (traj(i).cells == -1);
%     bndry = diff(double(nocells));
%     merge_with_intrp = merge_with_intrp + sum( (bndry>0) );
%     pts_intrp = pts_intrp + sum(nocells);
% end
% fprintf(1, 'total traj= %d, merged with interpol= %d, total pts interpol= %d, per traj= %d\n',...
%     length(traj), merge_with_intrp, pts_intrp, pts_intrp/length(traj) );

% counts of end==beg, end+1==beg, end<beg-1
cnts = zeros(1,3);
pts_intrp = 0;
merges = [traj.merge];
for i = 1:2:length(merges)
    bin = min(2, merges(i+1) - merges(i)) + 1;
    cnts(bin) = cnts(bin) + 1;
    if( bin==3 )
        pts_intrp = pts_intrp + merges(i+1) - merges(i);
    end
end

fprintf(1, '  total traj= %d, # mergers= %d, time spacing 0,1,>=2 %d %d %d, total pts interpol= %d\n',...
    length(traj), sum(cnts), cnts, pts_intrp);


function ct = cnt_cell_times(traj)
% count the number of cell # > 0 in all trajectories
ct = 0;
for i = 1:length(traj)
    ct = ct + sum( traj(i).cells > 0 );
end
    
function histTrajTimes(traj, title_str)
% histograms of traj lengths and beg, end times
ends = [traj.end];
begs = [traj.beg];
ntimes = max([ends, begs]);
dlt = floor(ntimes/20)+1;
bins = floor(dlt/2) + (1:dlt:ntimes);

subplot(1,2,1);
hist((ends - begs + 1), bins);  title(['length hist ', num2str(length(traj)), title_str]);
cts0 = hist(begs, bins);
cts1 = hist(ends, bins);
subplot(1,2,2)
bar(bins, [cts0', cts1'], 'group'); title('trajectory begin, end times');
    

