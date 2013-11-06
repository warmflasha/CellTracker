function peaks=matchFramesEDS(peaks)
%
%   peaks=MatchFrames(peaks)
%
% Compute the optimum matching between sucessive frames and update
% peaks{frame}(:,4) which carries the index in frame+1 that cell matched to
%
% The routine computes cutoffs to define the top (out of focus cells) and
% eliminates these from each frame before matching frames. It computes the
% mean and std of displacement of matched cells from frame to frame for the
% first few frames to establish over what distance a match is allowed. More
% diagnostics returned for each match than in AW routine. Uses
%   checkAssociation() &
%   initializeAssociationMatrix() &
%   doOneMove()  routines from AW
%
% TODO should include change in area or area./fluor in defn of cost matrix.
% Move the determination of dst_dummy to separate routine to call in
% findBirthNodes and remove global birthNodeParam. Use mask for CCC
%

global userParam
global birthNodeParam

% optionally eliminate diffuse cells on top of chamber
if isfield(userParam, 'useCCC') && userParam.useCCC
    [min_top, std_bot] = cellsTopBottom(peaks, userParam.verboseCellTrackerEDS );
else
    min_top = Inf; std_bot = 0;
end

%check if distance parameter should be recomputed each step
if userParam.L < 0
    fixedDistParam  = 0;
else
    fixedDistParam = 1;
    dst_dummy = userParam.L;
end


% establish typical parameters for frame to frame change
% dst = [];
% for frame = 2:min(4, length(peaks))
%     cost = costMatrixEDS(peaks{frame-1}, peaks{frame}, userParam.L, min_top, std_bot);
%     [Ilink, Jlink] = match1Frame(cost);
%     ok = find(Jlink>0);
%     [mean_step, std_step, dst] = stats_xy_dst(peaks{frame-1}(Ilink(ok), 1:2), peaks{frame}(Jlink(ok), 1:2), dst);
% end
%
% dst_dummy = userParam.sclDstCost(1)*mean_step + userParam.sclDstCost(2)*std_step; % larger pairwise dst cost=Inf
% birthNodeParam.dst2dummy = dst_dummy;
%
% fprintf(1, 'matchFramesEDS using cutoff topcells= %d, std bottom cells= %d (Inf,0 -> do not filter out top cells)\n', min_top, std_bot);
% fprintf(1, '  (The defn of cutoff for topcells is in test4TopCells(). The std of this statistic for the bottom cells is given for ref)\n');
% fprintf(1, '  From few frames, mean,std of nuc movement= %d %d, max dst for match= %d\n', mean_step, std_step, dst_dummy);

for frame = 2:length(peaks)
    
    if ~fixedDistParam
        dst_dummy = computeDistParam(peaks{frame}(:,[1 2]));
    end
    
    cost = costMatrixEDS(peaks{frame-1}, peaks{frame}, dst_dummy, min_top); % C(i,j) is cost of associating i with j
    [Ilink, Jlink] = match1Frame(cost);
    peaks{frame-1}(Ilink,4) = Jlink;
    cc = compute_cost(Ilink, Jlink, [], cost);
    tf = test4TopCells(peaks{frame-1}(:,3), peaks{frame-1}(:,5), min_top);
    fprintf(1, '  matched frame= %d, total nuc= %d, matched nuc= %d, top nuc= %d, min_cost= %d\n',...
        frame-1, length(Ilink)-1, length(find(Jlink>0)), sum(tf), cc);
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%

function [Ilink, Jlink] = match1Frame(cost)
%
A=initializeAssociationMatrix(cost); %intialize the association matrix

if ~checkAssociation(A) % check A for consistency
    disp('Error: association matrix failed consistency check');
    return
end

finished = 0;
while ~finished
    [A finished] = doOneMove(A,cost);
end

if ~checkAssociation(A) % check A for consistency
    disp('Error: association matrix failed consistency check');
    return
end

osize = size(cost,1) - 1;
nsize = size(cost,2) - 1;
% Convert link matrix to linked list representation
[Ilink,Jlink] = find(A(1:osize,:));
% if link is to dummy particle, set index to -1
Jlink(find(Jlink==(nsize+1))) = -1;
% disp(sprintf('Failed to match %d out of %d objects in previous frame',...
%     length(find(Jlink==-1)),osize));
% disp(sprintf('Failed to match %d out of %d objects in current frame',...
%     length(find(A(osize+1,1:nsize))),nsize));

% set linked list indices
% peaks0(Ilink,4) = Jlink;

function [mean0, std0, dst] = stats_xy_dst(xy0, xy1, dst0)
% accumulate list of distance between corresponding xy points and compute
% mean, std. xy0,1(:,2)
% First call with dst = [], subsequent calls add points to dst

diff = xy0 - xy1;
dst = diff(:,1).^2 + diff(:,2).^2;
dst = sqrt(dst);
dst = [dst0; dst];
mean0 = mean(dst);
std0 = std(dst);



function cc = compute_cost(Ilink, Jlink, peaks_data, cost)
% compute cost using either the link data or peaks (call with
% peaks{frame-1}

cc = 0;
if isempty(Ilink)
    Jlink = peaks_data(:,4);
    ok = find(Jlink>0);
    for ii = 1:length(ok)
        cc = cc + cost(ok(ii), Jlink(ok(ii)) );
    end
    
else
    ok = find(Jlink>0);
    for ii = 1:length(ok)
        % [ok(ii), Ilink(ok(ii)), Jlink(ok(ii)), cost(Ilink(ok(ii)), Jlink(ok(ii)) )]
        cc = cc + cost(Ilink(ok(ii)), Jlink(ok(ii)) );
    end
end
osize = size(cost,1) -1;
nsize = size(cost,2) -1;
% cost for no match * ( number of old and new nuclei not matched )
cc = cc + cost(end, end)*( osize - length(ok) + nsize - length(ok) );


function dst_dummy=computeDistParam(positions)
%compute the distance parameter for tracker

distances=ipdm(positions);
sort_distances = sort(distances,2);
mean_nn_dist = mean(sort_distances(:,2));
dst_dummy = mean_nn_dist*0.5;


%%%%%%%%%%%%%%%% AW routines with global osize nsize omitted
%
% function A=initializeAssociationMatrix(C)
% % A=initializeAssociationMatrix(C)
% %-------------------
% % function to initialize the association matrix
% % taken from matlab tracker
%
% osize = size(C,1) - 1;
% nsize = size(C,2) - 1;
%
% A=zeros(size(C));
%
% for i=1:osize
%     % sort costs of real particles
%     [srtcst,srtidx] = sort(C(i,:));
%     % append index of dummy particle
%     iidx = 1;
%     dumidx = find(srtidx==(nsize+1));
%     % search for available particle of smallest cost or dummy
%     while and(sum(A(:,srtidx(iidx)))~=0, iidx<dumidx), % particle must not be taken
%         iidx = iidx + 1;                               % AND cost must be less than dummy
%     end;
%     A(i,srtidx(iidx)) = 1;
% end;
% % set dummy particle for columns with no entry
% s = sum(A,1);
% A(osize+1,s < 1) = 1;
% % dummy always corresponds to dummy
% A(osize+1,nsize+1) = 1;
%
% function ch=checkAssociation(A)
% % ch=checkAssociation(A)
% %---------------------------
% % check association matrix for consistency
%
% osize = size(A,1) -1;
% nsize = size(A,2) -1;
%
% ch = 1;
% s = sum(A(:,1:nsize),1);
% if find(s(1:nsize)~=1),
%     disp('Inconsistent initial matrix A. Columns: ');
%     find(s(1:nsize)~=1)
%     ch = 0;
% end;
% s = sum(A(1:osize,:),2);
% if find(s(1:osize)~=1),
%     disp('Inconsistent initial matrix A. Rows:');
%     find(s(1:osize)~=1)
%     ch=0;
% end
