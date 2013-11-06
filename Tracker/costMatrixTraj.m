function C =  costMatrixTraj(stats0, stats1, cost2dummy, maskCCC)
%
%       C = costMatrixTraj(stats0, stats1, cost2dummy, maskCCC) 
%
% to be used for merging trajectories
% stats0 is data for 'ends' and stats1 is data for 'beginnings' of other traj
% stats = xy_area_time(:,4) matrix, and cost2dummy is cost to assoc with dummy
% cell in distance units (ie to be compared with dst from xy data).
%   maskCCC defines the area within CCC image where a cell can be. mask =1 in
% boundary, =0 in fluid. If mask = size(img)= [m,n] then code assumes corners of
% boundary are (0,0), (m+1,0), (0,n+1), (m+1, n+1), and fluid occupies all
% visible pixels.
%
% C(i,j) is the cost associated with linking i stats0 <--> j stats1 data
%   cost = distance if time0 (=stats(i,4)) < time1
%   cost = Inf      if time0 >= time1
%
% With osize = # cells in stats0, nsize = # cells in stats1
% C(osize+1, j) = create j from boundary (cost ~ distance nearest boundary)
% C(osize+2, j) = cost j is unmatched, does not exist in frame-1
% C(i, nsize+1,+2)  send i to boundary, i to dummy.
%
% TODO check for xy inside boundary when get full maskCCC

global nsize osize;

osize = size(stats0,1);
nsize = size(stats1,1); 

%calculate distances and area differences
distances=ipdm(stats0(:,1:2), stats1(:,1:2) );
%dareas = ipdm(stats0(:,3), stats1(:,3) );
dareas=zeros(osize,nsize);

t0_lt_t1 = true(osize, nsize);
t0_le_t1 = true(osize, nsize);
if size(stats0,2)==4
    for i = 1:osize
        t0 = stats0(i,4);
        t0_lt_t1(i, t0>=stats1(:,4) ) = 0;
        t0_le_t1(i, t0>stats1(:,4) ) = 0;
    end
end

% fill in cost for dummy
C=cost2dummy*ones(osize+2,nsize+2);

%Cost from areas and positions, real cells <-> real cells
Csub=distances+dareas;

%if > dummy cost set to Inf,  ?? might also set cells>boundary-dist to Inf
idhi= Csub>cost2dummy | ~t0_le_t1;
Csub(idhi)= Inf;
C(1:osize,1:nsize)=Csub;

%Boundaries  SET FOR TEST DATA XY [0,1]
%C(1:osize, nsize+1) = dst2bndry(stats0(:,1:2), [0,0]);
%C(osize+1, 1:nsize) = dst2bndry(stats1(:,1:2), [0,0]);
C(1:osize, nsize+1) = dst2Boundary(stats0(:,1:2), maskCCC );
C(osize+1, 1:nsize) = dst2Boundary(stats1(:,1:2), maskCCC );
% NB cost bndry to bndry is set to cost2dummy???

%%%%%%%%%%%%%%%%now separate fn%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% function dst = dst2bndry(xy, mask)
% % min distance from boundary, construed to be at xy= 0, size(img)+1
% % xy = x,y coordinates, pixel units, one per row,
% % mask = size(img) OR 
% % when use image of CCC, mask = 1 in boundary, 0 in fluid, used for dst transform.
% % dst = column vector of min distance
% %
% % for test data xy in [0,1) real, use mask=[0,0];
% 
% pts = size(xy,1);
% dst = zeros(pts, 1);
% 
% if length(mask) == 2
%     xmax = mask(2)+1;
%     ymax = mask(1)+1;
%     for n = 1:pts
%         dst(n) = min([xy(n,:), xmax-xy(n,1), ymax-xy(n,2)]);
%     end
%     if min(dst) < 1
%         fprintf(1, 'WARNING in costMatrixEDS negative distances to boundary, input correct sizeImg, currently= %d %d\n',...
%             mask);
%     end
% else
%     %%%% need impose a 1 pixel border, in mask, so behavior off from above
%     dd = bwdist(mask);
% end
%     
