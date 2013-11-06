function scatter_all(cobj, norm)
%
% make a scatter plot of all pairs of nuclear averaged intensities, and color
% points to indicate radial position. Norm points by nuclear average if flag
% set. Assumes either 2 or 3 colors in addition to DAPI
%   cobj = colony object
%   norm = 1 divide nuclear IF by DAPI & scatter plot, 
%        = 0 plot only the nuclear averaged IF
% There are a number of internal option parameters commented at the beginning,
% and also other types of plots that can be turned on|off
%
% TODO 
%   eliminate the very intense nuclei which are in metaphase and when
% normalizing IF, give rise to very low ratios.

% number of radii that are distinguished by color blue-red-> center-edge
ncolor = 6;
cmap = colormap(jet(ncolor));

% drop all nuclei outside of colony radius
truncate = 1;
% drop IF data beyond mean + std*limit if limit>0 otherwise keep all data
limit = 4;
% scatter plot of the unnormed IF data vs nuclear intensity, using 3 colors. One
% sees outliers in DAPI level which are in metaphase
scatter_vs_nuc = 1;
% radial plot of average nuclear size, and number of nuclei per ring.
% Discordance between the two can mean problems in detecting nuclei, but if real
% reflects uneven cell density in colony.
density_plot = 1;

nIF = (size(cobj.data,2)-1)/2 - 3;
coord = bsxfun(@minus,cobj.data(:,1:2),cobj.center);
radius = sqrt(sum(coord.*coord,2));
radius = ceil(ncolor * radius/cobj.radius);
if truncate
    npts = length(radius);
    data = cobj.data(radius<=ncolor,6:2:(end-2) );
    nuc  = cobj.data(radius<=ncolor, 5);
    radius(radius>ncolor) = [];
    fprintf('dropped %d nuclei outside of colony radius= %5.1f\n',...
        npts - length(radius), cobj.radius);
else
    data = cobj.data(:,6:2:(end-2) );
    nuc  = cobj.data(:, 5);
    npts = sum(radius>ncolor);
    radius = min(radius, ncolor);
    fprintf('found %d nuclei outside of colony radius\n', npts);
end

if limit>0
    thresh = mean(data) + limit*std(data);
    over = data > ones(size(data,1),1)*thresh;
    kill = logical(sum(over,2));   % any row with entry > 0 dies
    data(kill,:) = [];
    nuc(kill) = [];
    radius(kill) = [];
    over = sum(over);
    fprintf('dropped sum of %d %d %d points since one IF > mean + %d*std\n', over, limit);
end

if scatter_vs_nuc 
    figure
    hold on
    symb = {'.r', '.g', '.b'};
    for i = 1:nIF
        plot(nuc, data(:,i), symb{i});
    end
    title('IF(data) vs DAPI, rgb = w1,2,3');
    hold off
end

if density_plot
    binsize = 50;  max_bin = ceil(cobj.radius/binsize);
    [radAvr, cellsbin] = radialAverage(cobj, 3, 0, binsize);
    radAvr = radAvr(1:max_bin);  cellsbin = cellsbin(1:max_bin);
    xx = binsize*(1:length(radAvr)) - binsize/2;
    % 2*pi*xx*binsize / cellsbin should be comparable to radAvr time some cst
    areacell = pi*binsize*xx ./ (cellsbin+1)';
    figure, plot(xx,radAvr,'-r', xx(1:(end-1)),areacell(1:(end-1)),'-g'); 
    title('average nuc area(r), area-ring/#cells(g) vs radius')
end
    
if norm
    for i = 6:2:(size(cobj.data,2)-2)
        data(:,i/2-2) = data(:,i/2-2) ./ nuc;
    end
    max_norm = 3.0;
    nover = sum(sum(data>max_norm));
    if nover
        data = min(data, max_norm);
        fprintf('in ratio IF/DAPI truncated %d pts to %d\n', nover, max_norm);
    end
end

figure
plot1scatter(data(:,1),data(:,2), radius, cmap);
title(['wavelength 2 vs 1, color->radius. Normalize by DAPI= ', num2str(norm)]);
if size(cobj.data,2) == 13
    figure
    plot1scatter(data(:,1),data(:,3), radius, cmap);
    title('w3 vs w1');
    figure
    plot1scatter(data(:,2),data(:,3), radius, cmap);
    title('w3 vs w2');
else
    fprintf('size cobj.data= %d %d unexpected\n', size(cobj.data) );
end
colorbar('YTickLabel', '')

return

function plot1scatter(xpt, ypt, radius, cmap)
% do one scatter plot. Need hold.. here when using subplot
ncolor = size(cmap,1);
hold on
for n = 1:ncolor
    pts = radius==n;
    plot(xpt(pts),ypt(pts), 'LineStyle','none', 'Marker','.', 'MarkerSize',5, 'color',cmap(n,:) );
end
hold off