function colonyColorPointPlot1(col,dcols,rescale_fac,ps, centerpos)
%function colonyColorPointPlot(col,dcols)
%---------------------------------------
%Colony scatter plot with points colored by data
%col -- colony object
%dcols -- columns for data, if length==1, use this col
%           if length==2, use 2nd one for norm
%ps = pointsize (default 12);

xdat=col.data(:,1);
ydat=col.data(:,2);

rad = col.radius;

if length(dcols)==1
    coldat=col.data(:,dcols);
elseif length(dcols)==2
    coldat=col.data(:,dcols(1))./col.data(:,dcols(2));
end


if ~exist('ps','var')
    ps=12;
end




if ~exist('centerpos','var')
    centerpos=1;
end


if (max(coldat) > 3)
    limit = 3;
else
    limit = max(coldat);
end
 
climitsr = linspace(0, limit, 5);

for i = 1:4
    climits{i} = [0 climitsr(i+1)];
end

figure('visible', 'off');

if centerpos
    xdat=bsxfun(@minus,xdat,mean(xdat));
    ydat=bsxfun(@minus,ydat,mean(ydat));
end



includeinds=sqrt(xdat.*xdat+ydat.*ydat) < rad;
xdat=xdat(includeinds); ydat=ydat(includeinds);
coldat=coldat(includeinds);

colormap('jet');
scatter(rescale_fac*xdat,rescale_fac*ydat,ps,coldat);
minx=min(xdat); maxx=max(xdat);
miny=min(ydat); maxy=max(ydat);

maxdiff=max(maxx-minx,maxy-miny);

   if (dcols(1) == 10)
    tit = 'ch 10';
   elseif (dcols(1) == 8)
    tit = 'ch 8';
   elseif (dcols(1) == 6)
    tit = 'ch 6';
   end
   
   for i = 1:4
       subplot(2,2,i);
       colormap('jet');
       scatter(rescale_fac*xdat,rescale_fac*ydat,ps,coldat);
       colorbar;
       caxis(climits{i});
       
       minx=min(xdat); maxx=max(xdat);
       miny=min(ydat); maxy=max(ydat);
       axis equal; axis(rescale_fac*[minx-50 minx+maxdiff+50 miny-50 miny+maxdiff+50]);
       
       
       title(tit, 'FontSize',18, 'FontWeight', 'bold');
       xlabel('Distance from center (um)');
       ylabel('Distance from center (um)');
   end


