function [A finished]=doOneMove(A,C)

global osize nsize;

% find unmade links with finite cost
todo = intersect(find(A(1:osize,1:nsize)==0),find(C(1:osize,1:nsize)<Inf));

% determine induced changes and reduced cost Cred for each
% candidate link insertion
[Icand,Jcand] = ind2sub([osize nsize],todo);
Cred = zeros(size(Icand));
Xcand = zeros(size(Icand));
Ycand = zeros(size(Icand));
for ic=1:length(Icand),
    Cred(ic) = C(Icand(ic),Jcand(ic));
    Xcand(ic) = find(A(Icand(ic),:)==1);
    Ycand(ic) = find(A(:,Jcand(ic))==1);
    Cred(ic) = Cred(ic)-C(Icand(ic),Xcand(ic))-C(Ycand(ic),Jcand(ic));
    Cred(ic) = Cred(ic)+C(Ycand(ic),Xcand(ic));
end;

% find minimum cost and corresponding action
[minc,mini] = min(Cred);

% if minimum is < 0, link addition is favorable
if minc < -1e-10,
    % add link and update dependencies to preserve topology
    A(Icand(mini),Jcand(mini)) = 1;
    A(Ycand(mini),Jcand(mini)) = 0;
    A(Icand(mini),Xcand(mini)) = 0;
    A(Ycand(mini),Xcand(mini)) = 1;
    finished = 0;
else
    % done if best change is no more an improvement
    finished = 1;
end;
