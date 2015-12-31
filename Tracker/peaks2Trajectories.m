function trajectory = peaks2Trajectories(peaks)
%
% Take the peaks{} cell array from AW and create trajectory array..

ntimes = length(peaks);

% fill in peaks{nt-1}(cell, 4) with cell it matches in frame nt. peaks{}(:,4) = -1 if no
% match to following time
% for nt = 2:ntimes
%     peaks = MatchFrames(peaks, nt);  
% end

% create (active) trajectory struct array with fields
%   beg     first time
%   end     last time
%   cells   list of end-beg+1 cell numbers that are linked by peaks{}
%   x       list of x positions copies from peaks{}
%   y       ibid
%   area    nuclear area, copied from peaks
%   data    peaks col 5:end if exist ie [3, #times] matrix
%   colszdata 9th column of peaks, has the colony size in it            %AN
% NB time is column number eg x is row vector
%
% copy it to output trajectory struct when traj terminates

% initialize the 'active' trajectories, ie those still growing
ncells = size(peaks{1}, 1);
ntraj = ncells;
active = struct();  % to allow growth in loop with no warnings
for n = 1:ncells
    active(n).beg = 1;
    active(n).end = 1;
    active(n).cells = n;
    active(n).x = peaks{1}(n,1);
    active(n).y = peaks{1}(n,2);
    active(n).area = peaks{1}(n,3);
    active(n).data = peaks{1}(n,5:end);
    %active(n).colszdata = peaks{1}(n,9);%AN
end

trajectory = [];  verbose = 0;
for nt = 2:ntimes
    ncells = size(peaks{nt}, 1);
    % cells at time nt that are NOT matched to any cell at nt-1
    if isempty(peaks{nt-1})
        not_matched = 1:ncells;
    else
        not_matched = setdiff(1:ncells, peaks{nt-1}(:,4)');
    end
    
    for tt = 1:ntraj
        cell = active(tt).cells(end);
        match = peaks{nt-1}(cell,4);
        if match > 0
            active(tt).end = nt;
            active(tt).cells = [active(tt).cells, match];
            active(tt).x = [active(tt).x, peaks{nt}(match,1)];  %% CHECK
            active(tt).y = [active(tt).y, peaks{nt}(match,2)];
            active(tt).area = [active(tt).area, peaks{nt}(match,3)];
            active(tt).data = [active(tt).data; peaks{nt}(match,5:end)];
            %active(tt).colszdata = [active(tt).colszdata; peaks{nt}(match,9)];%AN
        else
            trajectory = [trajectory, active(tt)];
            active(tt).end = -1;
        end
        if verbose && ~isempty(trajectory)
            trajectory(end)
        end
    end
    ends = [active.end];
    active = active(ends>0);
    ntraj = length(active);
    
    for cc = not_matched
        ntraj = ntraj + 1;
        active(ntraj).beg = nt;
        active(ntraj).end = nt;
        active(ntraj).cells = cc;
        active(ntraj).x = peaks{nt}(cc,1);
        active(ntraj).y = peaks{nt}(cc,2);
        active(ntraj).area = peaks{nt}(cc,3);
        active(ntraj).data = peaks{nt}(cc,5:end);
        %active(ntraj).colszdata = peaks{nt}(cc,9);%AN
    end
end
trajectory = [trajectory, active];

return

          
    

    
