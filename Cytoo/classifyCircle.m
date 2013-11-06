function [circtype, ang]=classifyCircle(col,excludepts)

x=col.data(:,1); y=col.data(:,2);
if ~exist('excludepts','var')
    dists=ipdm([x y]);
    nndists=sort(dists);
    thresh=mean(nndists(2,:))+2*std(nndists(2,:));
    excludepts=nndists(2,:) > thresh;
end

x(excludepts)=[]; y(excludepts)=[];

ang = zeros(9,1);
good = ang; nogood = ang;

x=x-mean(x); y=y-mean(y);
dists = sqrt(x.*x+y.*y);
x=x/max(dists); y=y/max(dists);
dists = dists/max(dists);

good(1) = sum(dists > 0.2);
nogood(1) = sum(dists < 0.2);

good(2) = sum(dists > 0.5);
nogood(2) = sum(dists  < 0.5);

good(3) = sum(dists > 0.9);
nogood(3) = sum(dists < 0.9);

good(4)=sum(dists < 0.2 | dists > 0.4);
nogood(4)= sum(dists > 0.2 & dists < 0.4);

good(5)=sum(dists < 0.2 | dists > 0.6);
nogood(5)= sum(dists > 0.2 & dists < 0.6);

good(6)=sum(dists < 0.6 | dists > 0.8);
nogood(6)= sum(dists > 0.6 & dists < 0.8);

[ang(7), good(7), nogood(7)]=findAngle(@metric1,x,y);

[ang(8), good(8), nogood(8)]=findAngle(@metric2,x,y);

[ang(9), good(9), nogood(9)]=findAngle(@metric3,x,y);

areas = [pi*(1-0.2^2), pi*(1-0.5^2), pi*(1-0.9^2),...
    pi*0.2^2+pi*(1-0.4^2), pi*0.2^2+pi*(1-0.6^2), pi*0.6^2+pi*(1-0.8^2),...
    pi*(1-0.2^2), pi*340/360, pi*300/360];
badareas = pi - areas;


%[~, gind]= max((good./areas')./(nogood./badareas'));
[~, gind]= min(nogood./badareas');
ang=ang(gind);
circtype=gind;

end





function [ang, good, nogood]=findAngle(metric,x,y)

angbin = 0.1;
q=1;
for ang=0:angbin:2*pi
    nogood(q)=metric(ang,x,y);
    q=q+1;
end

[nogood, gind]= min(nogood);
ang = (gind-1)*angbin;
good = length(x) - nogood;
end

function ncell=metric1(ang,x,y)
   [x, y]=rotatebackbyang(ang,x,y);
   ncell=sum( sqrt((x-0.5).^2+y.^2) < 0.2);
end
    
function ncell=metric2(ang,x,y)
    [x,y]=rotatebackbyang(ang,x,y);
    ncell=sum( atan(y./x) > 0 & atan(y./x) < pi/9 & x > 0 & y > 0);
end

function ncell=metric3(ang,x,y)
    [x,y]=rotatebackbyang(ang,x,y);
    ncell=sum( atan(y./x) > 0 & atan(y./x) < pi/6 & x > 0 & y > 0);
end

function [xt, yt]=rotatebackbyang(ang,x,y)
    rotmat =[ cos(-ang) sin(ang); sin(-ang) cos(ang)]; %rotate backward by ang
    tcoord=rotmat*[x y]';
    xt=tcoord(1,:); yt=tcoord(2,:);
end