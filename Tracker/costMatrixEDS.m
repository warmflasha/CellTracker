function C = costMatrixEDS(peaksold, peaksnew, dst_dummy, min_top, CellMask)
%
%   C = costMatrixEDS(peaksold, peaksnew, dst_dummy, min_top, std_bot)
%
%----------------------------
% C(i,j) is the cost associated with linking i time <--> j time+1
%   peaks*      the peaks data array(:,7) for 2 times matched.
%   dst_dummy   distance > this are mapped to non cell ie -1
%   min_top     cutoff supplied to eliminate out of focus cells on top CCC
%   std_bot     STD for bottom cells of whatever criterion used for top/bot
%               distinction
% AW: modified 6/28/12 to reduce the cost of losing cells when they are
%     at the boundary

global osize nsize userParam  % needed for other AW routines in Tracker

posnew= [peaksnew(:,1) peaksnew(:,2)];
posold= [peaksold(:,1) peaksold(:,2)];

areaold = peaksold(:,3);
areanew = peaksnew(:,3);

nsize = length(areanew);
osize = length(areaold);



%calculate distances and area differences
distances=ipdm(posold,posnew);
%dareas = ipdm(areaold,areanew);
dareas=zeros(osize,nsize);
tobig = test4TopCells(areaold, peaksold(:,5), min_top);
dareas(tobig, :) = dst_dummy;
tobig = test4TopCells(areanew, peaksnew(:,5), min_top);
dareas(:, tobig) = dst_dummy;

% fill in cost for dummy: for cells in prev frame,
% this is min(dist to boundary, dst_dummy)
C = dst_dummy*ones(osize+1,nsize+1);
if exist('CellMask','var')
    d2b=distanceToBoundary(CellMask,posold);
else
    d2b=distanceToBoundary(userParam.sizeImg,posold);
end

xx=dst_dummy*ones(size(d2b));
d2b=min(d2b,xx);
C(1:osize,nsize+1)=d2b;

%Cost from areas and positions
Csub=distances+dareas;

%if > dummy cost set to Inf
idhi= Csub>dst_dummy;
Csub(idhi)= Inf;

C(1:osize,1:nsize)=Csub;
end
