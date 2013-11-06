function [mean0, std0] = statsTrajDst(traj)
%
% [mean0, std0] = statsTrajDst(trajectories)
%
%   Compute the list of all pairwise distances between matched cell in
% trajectory struct array. Return their mean and std for setting errors of
% matches.

dst = [];
for n = 1:length(traj)
    xx = traj(n).x;
    yy = traj(n).y;
    xx = diff(xx);
    yy = diff(yy);
    dst = [dst, sqrt( xx.^2 + yy.^2 )];
end

mean0 = mean(dst);
std0  = std(dst);