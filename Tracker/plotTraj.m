function plotTraj(traj, tend, tbeg, merged_traj)
% plot subsets of trajectories defined by a list time-end (eg [4,5,6]) to be
% potentially matched with a list of defined by a time-beg (eg [5,6,7,8] ).
% NB one trajectory can be in both categories if range >= min_traj_len
%
% optional fourth argument, merged_traj, plot only those that overlap tend
% trajectories ie the earliest ones in time.
%
% NB plots of traj will be inverted in y relative to imshow(nuclear-img)
% but the x,y coordinates will be consistently numbered as defined by
% impixelinfo on the imshow() image.

idx0 = get_traj_inrange('end', tend, traj);
idx1 = get_traj_inrange('beg', tbeg, traj);
traj0 = traj(idx0);
traj1 = traj(idx1);

hold on;
plot_traj(traj0, 'end', idx0, 'r', 0);
plot_traj(traj1, 'beg', idx1, 'g', 1);
title('Putative match from red to green traj, with (#, end|beg times)');
ylabel(['range tend= ', num2str(tend), ' range tbeg=', num2str(tbeg)]);
fprintf(1, 'plotted %d traj ends to match with %d traj beginnings\n', length(traj0), length(traj1) );

% overlay merged trajectories on the others
if nargin == 4 && isa(merged_traj, 'struct')
    idx2 = [];
    for i = 1:length(traj0)
        xyt = [traj0(i).x(2), traj0(i).y(2), traj0(i).beg+1]; % use second point since beg disappear if merge with same time
        idxx = find_xyt_traj(xyt(1), xyt(2), xyt(3), merged_traj);
        if isempty(idxx)
            fprintf(1, 'WARNING failed to find traj0 xyt= %d %d %d among merged traj\n', xyt);
        else
        % plot only traj that are resulted from merger and are longer
            if length(merged_traj(idxx).x) > length(traj0(i).x)
                idx2 = [idx2, idxx];
            end
        end
    end
    traj2 = merged_traj(idx2);
    plot_traj(traj2, 'beg', idx2, 'm', 2); % 'y' will not show in text print
    xlabel('merged traj that overlap red traj in magenta with beg point marked')
end
hold off;

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function idx = get_traj_inrange(type, range, traj)
data = [traj.(type)];
idx = [];
for rr = reshape(range, 1, []);
    idx = [idx, reshape(find(data == rr), 1, []) ];
end


function plot_traj(traj, type, idx, color, offset)

lent = length(traj);
time = [traj.(type)];
% plot lines black, and plots colored
for k = 1:lent
    plot(traj(k).x+offset, traj(k).y+offset, ['-' color]);
    plot(traj(k).x+offset, traj(k).y+offset, ['.' color]);  %%'Color', color, 'MarkerType', '.');
end

% label #traj, time on one end for each traj
if strcmp(type, 'beg')
    for k = 1:lent
        str = num2str([idx(k), time(k)]);
        text(traj(k).x(1)-4, traj(k).y(1), str, 'Color', color);
    end
elseif strcmp(type, 'end')
    for k = 1:lent
        str = num2str([idx(k), time(k)]);
        sft = length(str)/2;
        text(traj(k).x(end)-sft, traj(k).y(end), str, 'Color', color);
    end
else
    fprintf(1, 'WARNING bad option %d into plotTraj\n', type)
end
return

function idx = find_xyt_traj(x, y, time, traj)
idx = [];
for i = 1:length(traj)
    if time<traj(i).beg || time>traj(i).end
        continue
    end
    ptr = time - traj(i).beg +1;
    if abs(x - traj(i).x(ptr)) < 1.e-6
        if abs(y - traj(i).y(ptr)) < 1.e-6
            idx = i;
            return;
        else
            continue
        end
    else
        continue
    end
end
