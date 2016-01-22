function [cells, peaks] = peaksTraj2CellObj(peaks, traj)
%
%   [cells, peaks] = peaksTraj2AWCells(peaks, traj)
%
%
% peaks{frame}(#cell(actual nuc), :)  where cols of peaks are for input..
%   x, y, nuc_area, #cell-matched-next-frame or -1, nuc_marker_avr,...
%   fluor_in_nuc, fluor_in_cyto)   %% 7 columns input
%
% peaks OUTPUT  add 8th col with cell (ie traj) number or -1 if not in a
% trajectory.  NB anything in peaks{}(:, 9:end) is just copied to output
%
% trajectory struct array is defined with fields: (from mainPeaks2Trajectories
%   beg     first time (int >=1 by defn)
%   end     last time
%   merge   row vector of [end, beg] times/frame#, end<=beg, of trajectories that
%           were merged, or []. beg_i <= end_(i+1) - (minTrajLen-1)
%   cells   list of (1,end-beg+1) cell numbers corresponding to x,y,area at given time
%   cells   = -1 for interpolated times, otherwise >0
%   x       list of end-beg+1 x positions copied from peaks{} or interpolated
%   y       ibid   NB all data row matrix, time==column number
%   area    nuclear area, copied from peaks or interpolated.
%   data    anything in cols 5:end of peaks{} organized as mtx(#data, times)
%
% cells fields:
%   onframes    list of consecutive ints of the frames included in the trajectory
%           may include interpolated times, where there is no cell
    
% fill in end+1 col of peaks with trajectory number for given time and cell#
% or -1 if cell is not on traj (ie a short trajectory dropped, or merger).

ncol_data = find_last_col_fluor(peaks);

for n = 1:length(peaks)
    ncells = size(peaks{n}, 1);
    peaks{n}(:,ncol_data+1) = -ones(ncells, 1);
end

for i = 1:length(traj)
    for n = (traj(i).beg):(traj(i).end)  % frame number 
        ncell = traj(i).cells(n - traj(i).beg+ 1);
        if ncell > 0
            peaks{n}(ncell, ncol_data+1) = i;
        end
    end
end

for i = 1:length(traj)
    [data, onframes, merge]=traj2data(traj(i));
    cells(i)=dynCell(data,onframes);
end
end

function [data, onframes, merge] = traj2data(traj)
    nframes = traj.end - traj.beg + 1;
    onframes = (traj.beg):(traj.end);
    merge = traj.merge;
    data = zeros(nframes, 4+size(traj.data,2));
    data(:,1) = traj.x';
    data(:,2) = traj.y';
    data(:,3) = traj.area';
    data(:,4)=-1;
    data(:,5:end) = traj.data; 
end

function ncol = find_last_col_fluor(peaks)
% find the last column of peaks{} that is plausible fluor value
data = peaks{1};
ncol = size(data,2);  % incase exit without enough data
for nt = 2:length(peaks)
    data = [data; peaks{nt}];
    if size(data,1) > 1000
        break
    end
end
        
nn = size(data, 2);
for ncol = nn:-1:1
    if min(data(:,ncol))>=0 && max(data(:,ncol))>10
        break
    end
end
end