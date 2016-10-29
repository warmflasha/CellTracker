function C = CostMatrix(peaks,frame,Lparam)
% C = CostMatrix(peaks)
%----------------------------
% C(i,j) is the cost associated with linking i <--> j

global userParam nsize osize;

L=Lparam;

posnew= [peaks{frame}(:,1) peaks{frame}(:,2)];
posold= [peaks{frame-1}(:,1) peaks{frame-1}(:,2)];

areaold = peaks{frame-1}(:,3);
areanew = peaks{frame}(:,3);

nsize = length(areanew); osize = length(areaold);

%calculate distances and area differences
distances=ipdm(posold,posnew);
%dareas = ipdm(areaold,areanew);
dareas=zeros(osize,nsize);

% fill in cost for dummy
C=L*ones(osize+1,nsize+1);

%Cost from areas and positions
Csub=distances+dareas;

%if > dummy cost set to Inf
idhi= Csub>L;
Csub(idhi)= Inf;

C(1:osize,1:nsize)=Csub;
end
