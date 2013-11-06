function [Center Rad inds]=MCfitCircleToData(data)

nstep =4e2;
currCen=mean(data);
xdiff=max(data(:,1))-min(data(:,1));
ydiff=max(data(:,2))-min(data(:,2));

currRad=(xdiff+ydiff)/2;

currCost=CostFunction(data,currCen,currRad);

for ii=1:nstep
    [cNew rNew]=changeParam(currCen,currRad);
    [newCost coord]=CostFunction(data,cNew,rNew);
%     if ~mod(ii,10)
%         disp([int2str(ii) '  ' num2str(currCost)]);
%     end
    if newCost > currCost
        currCost=newCost;
        currRad=rNew;
        currCen=cNew;
        currCoord=coord;
    end
    
end
Center=currCen;
Rad=currRad;
inds = sqrt(sum(currCoord.*currCoord,2)) < Rad;

function [cost coord]=CostFunction(data,cen,rad)

coord=bsxfun(@minus,data,cen);
dist=sqrt(sum(coord.*coord,2));

inds = dist < rad;

den=sum(inds)/(pi*rad*rad);

cost=den*sum(inds);

function [cNew rNew]=changeParam(cen,rad)

itochange=randi(3);
fracchange=0.1*(2*rand-1);

if itochange==1
    cNew=[cen(1)*(1+fracchange) cen(2)];
    rNew=rad;
elseif itochange==2
    cNew=[cen(1) (1+fracchange)*cen(2)];
    rNew=rad;
elseif itochange==3
    rNew=rad*(1+fracchange);
    cNew=cen;
end
