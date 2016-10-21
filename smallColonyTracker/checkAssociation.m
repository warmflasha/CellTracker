function ch=checkAssociation(A)
% ch=checkAssociation(A)
%---------------------------
% check association matrix for consistency

global nsize osize;

ch = 1;
s = sum(A(:,1:nsize),1);
if find(s(1:nsize)~=1),
    disp('Inconsistent initial matrix A. Columns: ');
    find(s(1:nsize)~=1)
    ch = 0;
end;
s = sum(A(1:osize,:),2);
if find(s(1:osize)~=1),
    disp('Inconsistent initial matrix A. Rows:');
    find(s(1:osize)~=1)
    ch=0;
end;