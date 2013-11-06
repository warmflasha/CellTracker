function [cells, peaks] = peaksTraj2AWCells_Nluc(peaks, traj)
%
%   [cells, peaks] = peaksTraj2AWCells(peaks, traj)
%
% Create AW cells array that repackages the info in EDS traj struct array.
% Add cross ref in the 8th column of peaks{} to the cell/trajectory struct
% element to which that cell belongs.
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
%   merge   copied from trajectory struct, see above.
%   data    array(1:length(onframes), peaks{onframes}(#cell, :) )
%
% current defn of cells().data(:,4) differs from AW in case EDS merges two
% trajectories at a common time, ie two centers in one nucleus. AW copies
% peaks{}(:,4) entries at boundary time, I jump to numbering of nucleus in
% second trajectory, but other option is possible. See comments below
% flag..
%
% CHANGES 10/30/11 to accomodate optionally 3 fluor channels:
% peaks{}(:, ncol) will have either 7 or 9 cols on input, with additional
%   fluor nuc, cyto data on end. If rereading old peaks{} data that may
%   have gotten cell_number data added AND good=0|1 field added, check for
%   last column that has plausible fluor data ie > 0
% cells will have data related fields
%   data(:,1:4)     same as before, 1st 4 cols
%   fdata(:,1:3 or 1:5) with fluorescent data

ncol_data = find_last_col_fluor(peaks);
if ncol_data==7 || ncol_data==9
    fprintf(1, 'peaksTraj2AWCells: found %d cols in peaks{1} data (last of which is fluor) that define fluor channels(nuc+smad)= %d\n',...
        ncol_data, (ncol_data-3)/2 );
else
    fprintf(1, 'peaksTraj2AWCells: INVALID NUMBER OF COLS IN PEAKS{}= %d quitting\n',...
        ncol_data);
end
    
% fill in end+1 col of peaks with trajectory number for given time and cell#
% or -1 if cell is not on traj (ie a short trajectory dropped, or merger).

for n = 1:length(peaks)
    ncells = size(peaks{n}, 1);
    peaks{n}(:,ncol_data+1) = -ones(ncells, 1);
end
for i = 1:length(traj)
    for n = (traj(i).beg):(traj(i).end)  % frame number
        ncell = traj(i).cells(n - traj(i).beg + 1);
        if ncell > 0
            peaks{n}(ncell, ncol_data+1) = i;
        end
    end
end

cells = struct('onframes', {}, 'data', {}, 'fdata', {}, 'merge', {});
% number of columns in data field
flag_verify_nextcell = 0;

for i = 1:length(traj)
    nframes = traj(i).end - traj(i).beg + 1;
    cells(i).onframes = (traj(i).beg):(traj(i).end);
    cells(i).merge = traj(i).merge;
    data = zeros(nframes, 4);
    data(:,1) = traj(i).x';
    data(:,2) = traj(i).y';
    data(:,3) = traj(i).area';
    % traj.cells has number of current cell, shift to get next cell, -1 at
    % end to terminate
    data(:,4) = [traj(i).cells(2:end), -1];
    % other real valued data that was interpolated.
    %data(:,5:ncol_data) = (traj(i).data(1:(ncol_data-4),:))';
    
    cells(i).data = data;
    cells(i).fdata = (traj(i).data(1:(ncol_data-4),:))';
    
    % following check on indexing works if we define for trajectories that
    % merge at equal times (ie 2 centers 1 nucleus) traj.cell = [cell_pre,
    % cell_post(2:end)], this agrees with peaks{}(:,4) which points to next
    % cell matched. Currently using defn traj.cell = [cell_pre(1:(end-1),
    % cell_post] see mergeTrajectories/merge_trajectories()
    if flag_verify_nextcell
        for nn = 1:nframes
            ncell = traj(i).cells(nn);
            if ncell > 0
                frame = cells(i).onframes(nn);
                mapped2 = peaks{frame}(ncell,4);
                % data check that traj has not lost a cell match from peaks
                if(mapped2 > 0 && nn<nframes)
                    if mapped2 ~= traj(i).cells(nn+1)
                        fprintf(1, 'WARNING: next cell index inconsistent in peaksTraj2AWCells..peaks-> %d\n', mapped2);
                        traj(i).cells
                    end
                end
            end
        end
    end
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