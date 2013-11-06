function drawcircle(cen,radius,col)

if ~exist('col','var')
    col='k';
end

tt=0:0.1:6.3;
xx=cos(tt); yy=sin(tt);
xx=xx*radius+cen(1);
yy=yy*radius+cen(2);

plot(xx,yy,col,'LineWidth',2);