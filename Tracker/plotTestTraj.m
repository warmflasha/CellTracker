function plotTestTraj(cell, traj)
% take the known cells from makeTestTrajectories and the reconstructed
% trajectories and compare.

figure
hold on
for i = 1:length(cell)
    xx = cell(i).x;
    yy = cell(i).y;
    pts = find(xx>=0);
    color = 'k';
    if length(find(xx<0))
        color = 'r';
    end
    plot(xx(pts), yy(pts), 'Color', color )
end
title('from synthetic data: cell trajectories black, births in red');
hold off

figure
hold on
cmap = colormap(hsv(length(traj)));
for i = 1:length(traj)
    xx = traj(i).x;
    yy = traj(i).y;
    pts = find(xx>=0);
    plot(xx(pts), yy(pts), 'Color', cmap(i,:) )
end
title('merged trajectories inferred from mutated cell data');
hold off