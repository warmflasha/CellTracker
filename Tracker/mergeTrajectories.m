function trajectory = mergeTrajectories(trajectory)
% 
%   trajectory = mergeTrajectories(trajectory)
% 
% Take trajectory struct array and merge, allowing at most a merge_gap missing
% time points. Interpolate entries in traj fields, x, y, area. Fill in 'cell'
% field with -1.  Compute a new cost matrix for merging ends of trajectories
% that allows for cells <-> boundaries with cost = min-dst-to-boundary. Set cost
% for cell match to dummy based on observed dst change for cells matched between
% successive times. Cost = Inf if end of first traj > beg of second traj.
%
% Greedy algorithm for merging ends. Take a range of ends for the first
% (early) trajectory and a range of beginings for following traj. Do the cost
% matching and accept only traj mergers for the earliest of the end times.
% Increment the end times by 1 and repeat.
%
% BUGS with matching multiple cells to boundary, choses dummy instead??

global userParam

merge_gap = userParam.mergeGap;         % time interval to group traj for merge, 2 and 4 almost same
min_traj_len = userParam.minTrajLen;
verbose = userParam.verboseCellTrackerEDS;    % =1 print stats for ensemble of traj
                                              % >=2 print details of all traj being merged

                
% mean, std of distance cell moves in one time step
[mean_step, std_step] = statsTrajDst(trajectory);
dt = userParam.mergeGap;
cost2dummy = userParam.sclDstCost(1)*dt*mean_step + userParam.sclDstCost(2)*sqrt(dt)*std_step;

if verbose
    params = [mean_step, std_step, cost2dummy];
    if min(params) > 4
        params = round(params);
    end
    fprintf(1, 'mergeTrajectories(): mean, std distance cell movements= %d, %d, dst cost cell->dummy= %d\n',...
        params );
    if verbose > 1
        fprintf(1, '  for all traj with time-end in range [], enumerate what they match to and count total # of traj beginnings available for match\n');
    end
end

tend = max([trajectory.end]);
for tt = min_traj_len:(tend - merge_gap - 1)
    % match band of times.
    % Idx* returns index into trajectory array, and stats(:,4) is matrix with
    % (x,y,ara,t_end) info for the idx trajectories.
    [idx0, stats0] = get_traj_between('end', tt, tt+merge_gap-1, trajectory);
    [idx1, stats1] = get_traj_between('beg', tt, tt+merge_gap, trajectory);
    if isempty(idx0) || isempty(idx1)
        continue
    end
    cost = costMatrixTraj(stats0, stats1, cost2dummy, userParam.sizeImg); 
    % NB jlink indexes relative to row numbers in stats* from 0 to 1
    jlink = match1Frame(cost);
    if verbose>1
        % Note these match stats refer to groups of traj, only traj(idx0)
        % with tend==tt will get matched in this pass
        fprintf(1, 'For t_end=[%d %d], #traj= %d, costMtx: %d->match, %d->bndry, %d->dummy, (%d free traj begs to match to)\n',...
            tt, tt+merge_gap-1, length(idx0), sum(jlink>0), sum(jlink==-1), sum(jlink==-2), length(idx1) );
    end
    % Need take matched trajectories out of circulation and redefine traj()
    trajectory = merge_trajectory(tt, jlink, idx0, idx1, trajectory, verbose);
end

function [idx, stats] = get_traj_between(type, t0, t1, trajectory)
% return the index in trajectory struct array for all those trajectories
% for which the times of type='beg' or type='end' fall within [t0,t1] inclusive.
% stats(:,4) = [x, y, area, time(beg or end)]

if isfield(trajectory, type)
    data = [trajectory.(type)];
    idx = find( data>=t0 & data <= t1 );
else
    fprintf(1, 'invalid type= %d input to get_traj_between()\n', type);
    idx = [];
    stats = [];
    return
end

traj0 = trajectory(idx);
npts = length(traj0);
stats = zeros(npts, 4);
if strcmp(type, 'end') 
    for n = 1:npts
        stats(n,1) = traj0(n).x(end);
        stats(n,2) = traj0(n).y(end);
        stats(n,3) = traj0(n).area(end); % dummy area
        stats(n,4) = traj0(n).end;
    end
else
    for n = 1:npts
        stats(n,1) = traj0(n).x(1);
        stats(n,2) = traj0(n).y(1);
        stats(n,3) = traj0(n).area(1); % dummy area
        stats(n,4) = traj0(n).beg;
    end
end

function trajectory = merge_trajectory(tt, jlink, idx0, idx1, trajectory, verbose)
% Take all trajectories that end at tt AND have a + jlink and merge.
% Mergers permitted bewteen traj that end and beg at same time, since
% presumably two local max detected in same physical nucleus.
% Return modified trajectory list.

to_remove = []; to_add = [];
for ii = 1:length(idx0)
    next = trajectory(idx0(ii));
    if next.end > tt || jlink(ii) < 0
        continue
    end
    merge2 = trajectory( idx1(jlink(ii)) );
    t0 = next.end;
    t1 = merge2.beg;
    next.merge = [next.merge, t0, t1];
    next.x = mergeTimeHistory(t0, t1, next.x, merge2.x, 'numeric');
    next.y = mergeTimeHistory(t0, t1, next.y, merge2.y, 'numeric');
    next.area = mergeTimeHistory(t0, t1, next.area, merge2.area, 'numeric');
    next.cells = mergeTimeHistory(t0, t1, next.cells, merge2.cells, 'cell');
    next.data = mergeTimeHistory(t0, t1, next.data, merge2.data, 'numeric') ;  %with multi dims, time==row 
    next.end  = merge2.end;
    % alternative way of defining merger...NB rest of data not included
%     if t0 < t1
%         next.x = [next.x, interpolate(t0, t1, next.x(end), merge2.x(1)), merge2.x];
%         next.y = [next.y, interpolate(t0, t1, next.y(end), merge2.y(1)), merge2.y];
%         next.area = [next.area, interpolate(t0, t1, next.area(end), merge2.area(1)), merge2.area ];
%         next.cells = [next.cells, -ones(1, t1-t0-1), merge2.cells];
%         next.end  = merge2.end;
%     elseif t0==t1  % arb keep end of first trajectory and drop first point of second one
%         next.x = [next.x, merge2.x(2:end)];
%         next.y = [next.y, merge2.y(2:end)];
%         next.area = [next.area, merge2.area(2:end)];
%         next.cells = [next.cells, merge2.cells(2:end)]; %%% defn disagrees with above
%         next.end = merge2.end;
%     else
%         fprintf(1,'WARNING invalid data to merge_trajectory t0= %d > t1=%d\n', t0,t1);
%     end
        
    if verbose>2
        fprintf(1,'merging trajectories # %d (tend= %d) with %d (tbeg= %d)\n',...
            idx0(ii), t0, idx1(jlink(ii)), t1 );
        trajectory(idx0(ii))
        trajectory(idx1(jlink(ii)) )
        next
    end
    to_remove = [to_remove, idx0(ii), idx1(jlink(ii))];
    to_add = [to_add, next];
end

if verbose>1 && ~isempty(to_remove)
    fprintf(1, 'actually merged %d trajectories with t_end= %d with traj with (tbeg dst len)..\n', length(to_remove)/2, tt);
    for i = 2:2:length(to_remove)
        idx0 = to_remove(i) - 1;
        idx1 = to_remove(i);
        dst = dst2traj(trajectory(idx0), trajectory(idx1));
        fprintf(1,'%d %d %d, ',trajectory(idx1).beg, round(100*dst)/100, length(trajectory(idx1).x) );
    end
    fprintf(1,'\n');
end
    
trajectory(to_remove) = [];
trajectory = [trajectory, to_add];
return

function data = interpolate(t0, t1, d0, d1)
% for integer times t0<t1, do linear interpolation of data between d0 and d1

data = [];
if t0 < t1-1
    incr = (d1 - d0)/(t1 - t0);
    data = zeros(1, t1-t0-1);
    for i = 1:(t1-t0-1)
        data(i) = d0 + incr*i;
    end
end
if t0 >= t1
    fprintf(1, 'WARNING: bad data into merge_trajectory %d %d %d %d\n', t0, t1, d0, d1);
end

function dst = dst2traj(traj0, traj1)
diff = [traj0.x(end) - traj1.x(1), traj0.y(end) - traj1.y(1)];
dst = sqrt( sum(diff.^2) );
    
    
    