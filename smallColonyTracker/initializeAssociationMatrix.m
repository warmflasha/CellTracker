function A=initializeAssociationMatrix(C)
% A=initializeAssociationMatrix(C)
%-------------------
% function to initialize the association matrix
% taken from matlab tracker

global nsize osize;

A=zeros(osize+1,nsize+1);

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