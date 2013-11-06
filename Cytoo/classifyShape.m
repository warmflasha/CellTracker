function [shape, metrics, excludepts]=classifyShape(col,showfig)
%function [shape, metrics]=classifyShape(col,showfig)
%-----------------------------------------------------------
%function to determine shape of colony. 
%col - a colony object
%shape - determine shape, possibilities: 'circ','rect', and 'tri'
%metrics - returns measures of circularity, rectangularity, and
%triangularity

if ~exist('showfig','var')
    showfig=0;
end

x=col.data(:,1); y=col.data(:,2);
xt=x-mean(x); yt=y-mean(y);

%plot all cells
if showfig
    plot(xt,yt,'r.');
    hold on;
end

%get n.n dists, exclude cells that are too far
dists=ipdm([xt yt]);
nndists=sort(dists);
thresh=mean(nndists(2,:))+2*std(nndists(2,:));

excludepts=nndists(2,:) > thresh;
xt(excludepts)=[]; yt(excludepts)=[];

dists(excludepts,:)=[];
dists(:,excludepts)=[];

%get convex hull, compute circularity, rectangularity,triangularity
[k, ar]=convhull(xt,yt);
perim=0;
for ii=1:(length(k)-1)
    perim=perim+dists(k(ii),k(ii+1));
end
circ=4*pi*ar/perim^2;
rect=ar/((max(xt)-min(xt))*(max(yt)-min(yt)));

[trix, triy]=minboundtri(xt,yt);
triar=polyarea(trix,triy);
tri=ar/triar;

if showfig
    plot(xt(k),yt(k),'c.-');
end

metrics.circ = circ;
metrics.rect = rect;
metrics.tri = tri;

[~,shapeind]=max([circ, rect, tri]);
switch shapeind
    case 1
        shape='circ';
    case 2
        shape='rect';
    case 3
        shape='tri';
end


%BELOW ONLY KIND OF WORKED TO REMOVE STRAIGHT EDGES IN CONVEX HULL, NOT
%REALLY NECESSARY GIVEN THAT THE ABOVE WORKS WELL. 
%TOL = 0.5; %deviation from straight allowed in radians
% removeinds=false(length(k),1);
% ksave = k;
% k(end+1)=k(2);
% 
% for ii=1:(length(k)-2)
%     vec1=[x(k(ii+2))-x(k(ii+1))  y(k(ii+2))-y(k(ii+1))];
%     vec2=[x(k(ii+1))-x(k(ii)) y(k(ii+1))-y(k(ii))];
%     ang=acos(vec1*vec2'/norm(vec1)/norm(vec2));
%     if ang < TOL || pi-ang < TOL
%         removeinds(ii+1)=true;
%     end
%     text(xt(k(ii+1)),yt(k(ii+1)),[int2str(ii) ':  ' num2str(ang)]);
% end
% 
% k=ksave;
% 
% if(removeinds(end))
%     removeinds(1)=true;
% end
% k(removeinds)=[];
% 
% if isempty(k)
%     shape=0;
%     return;
% end
% 
% if removeinds(1)
%     k(end+1)=k(1);
% end
% 
% if showfig
% plot(xt(k),yt(k),'m.-');
% end
% 
% %exclude close points in convex hull
% dist_ch=ipdm([xt(k(1:(end-1))) yt(k(1:(end-1)))]);
% [i, j]=find(dist_ch < 2*thresh);
% toomany= i >= j;
% i(toomany)=[]; j(toomany)=[];
% if any(i==1)
%     i(end+1)=length(k);
%     i=unique(i);
% end
%     
% k(i)=[];
% if any(i==1)
%     k(end+1)=k(1);
% end
% 
% if showfig
% plot(xt(k),yt(k),'g.-');
% end


