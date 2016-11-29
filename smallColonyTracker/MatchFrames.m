function peaks=MatchFrames(peaks,frame,Lparam)
%peaks=MatchFrames(peaks,frame)
% ---------------------------
% Compute the optimum matching between sucessive frames
%

global nsize osize;


C = CostMatrix(peaks,frame,Lparam); % C(i,j) is cost of associating i with j
A=initializeAssociationMatrix(C); %intialize the association matrix

if ~checkAssociation(A) % check A for consistency
    disp('Error: association matrix failed consistency check');
    return
end

finished = 0;
while ~finished
    [A, finished] = doOneMove(A,C);
end


if ~checkAssociation(A) % check A for consistency
    disp('Error: association matrix failed consistency check');
    return
end


% Convert link matrix to linked list representation
[Ilink,Jlink] = find(A(1:osize,:));
% if link is to dummy particle, set index to -1
Jlink(find(Jlink==(nsize+1))) = -1;

% set linked list indices
peaks{frame-1}(Ilink,4) = Jlink;
end