function Jlink = match1Frame(cost)
%
% Jlink = match1Frame(xyarea0, xyarea1, cost)
%
%   Compute the optimum matching between sucessive frames, and return array
% Jlink such that xyarea0(i) -> xyarea1(Jlink(i)) if Jlink>0 otherwise
% Jlink(i) = [-1, -2] implies i -> [boundary, dummy];
%

global nsize osize;

A=initAssociationMatrix(cost); %intialize the association matrix

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

% Convert link matrix to linked list representation
[Ilink,Jlink] = find(A(1:osize,:));
% if link is to [boundary, dummy], set index to [-1, -2]
Jlink(find(Jlink==(nsize+1))) = -1;
Jlink(find(Jlink==(nsize+2))) = -2;
% reorder so that Jlink is the new index that old idx=1,2,.. mapped to
[range, permu] = sort(Ilink);
Jlink = Jlink(permu);

if osize ~= length(range) || ~all(range' == 1:osize)
    printf(1, 'WARNING index off in match1Frame, Ilink, Jlink, range, permu\n');
    Ilink, Jlink, range, permu
end

%fprintf(1, 'Of %d cells T0, %d matched, %d -> bndry, %d -> dummy. Matched %d out of %d cells T1\n',...
%   osize, sum(Jlink>0), sum(Jlink==-1), sum(Jlink==-2), length(find(A(1:osize,1:nsize))), nsize);

return

function A=initAssociationMatrix(C)
%
% assume last row/col of C corresponds to dummy particle, others are real
% cell-cell distances or cell-boundary dist (should allow multiple
% cell-bndry links)

A = zeros(size(C));
osize = size(C,1) - 1;
nsize = size(C,2) - 1;

for i=1:osize,
    % sort costs of real particles
    [srtcst,srtidx] = sort(C(i,:));
    % append index of dummy particle
    iidx = 1;
    dumidx = find(srtidx==(nsize+1));
    % search for available particle of smallest cost or dummy
    while and(sum(A(:,srtidx(iidx)))~=0, iidx<dumidx), % particle must not be taken
        iidx = iidx + 1;                               % AND cost must be less than dummy
    end;
    A(i,srtidx(iidx)) = 1;
end;
% set dummy particle for columns with no entry
s = sum(A,1);
A(osize+1,s < 1) = 1;
% dummy always corresponds to dummy
A(osize+1,nsize+1) = 1;
