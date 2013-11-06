function runColonyMovieStats(dirname, keyword, frames)
%
%   runColonyMovieStats(dirname, keyword, frames)
%
% Sloppy program to plot stats over time for a matfile made for a smad movie
% Parameters to set done internally after reading data, in the various
% subroutines
%

matfile = dir( fullfile(dirname, ['*',keyword,'*mat']) );
if length(matfile) > 1 
    fprintf(1, 'found more than one mat file in dir= %s with keyword= %s\n', dirname, keyword);
    matfile.name;
    return
elseif length(matfile) == 1
    matfile = fullfile(dirname, matfile.name);
    mat = load(matfile);  % for certain fns can be more selective about what to lead
    imgfiles = mat.imgfiles;
    fprintf(1, 'read matfile= %s, len imgfiles= %d, imgfiles(1)=\n',...
        matfile, length(imgfiles) );
    imgfiles(1)
    if max(frames) > length(imgfiles)
        fprintf(1, 'WARNING input frames exceeds length of imfiles\n');
        frames
    end
else
    fprintf(1, 'No file found in %s with keyword = %s\n', dirname, keyword);
    return
end

% For cells that exist from beginning to end of frames, compute various stuff
% eg for pairs of point initially close and at some radius do a scatter plot of
% rms distance at final time vs initial radius
%
% plot_cell_traj(mat.cells, mat.peaks, frames)
%
% radial plots of various averages at several times. The first argument type
% defines what gets plotted. It can be simple ratios of fluorescent data in
% peaks, pair correlation fns of fluor between points that are close, or time
% derivative data. See code.
plot_radial_avr(3, matfile, mat.userParam, mat.peaks, frames)
return

%%%%%%%%%%%%%%%%%%%%%%%%%% top level fns %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_radial_avr(type, matfile, userParam, peaks, frames)
%
% plot a radially binned average for variout times.
%   type   defined in the main loop by the function which computes means
%
% columns are x,y,nucarea,match-indx, nucfluor,smadnuc,smaddonut, (..)
%
binsize = 50;   % size of radial bins in pixels
col2avr = 5;    % column of data to average
col2norm = 6;   % col of data to use as norm
limit = 40;     % max distance of pairs of nuclei correlated for type=2
mincellsbin = 10;   % to eliminate bins with few points.

nf = length(frames);
% nb the number of radial points can change.
msg0 = sprintf('for matfile= %s, ',matfile);
for ii = 1:nf
    cobj(ii) = colony(peaks{frames(ii)});
    pix_cell = round( (pi*cobj(ii).radius^2)/cobj(ii).ncells );
    if type==1  % radial binned image values
        [radAvr, cellsbin] = radialAverage(cobj(ii), col2avr, col2norm, binsize);
        msg1 = 'radial average';
    elseif type==2  % pair correlation for nearby cells of image values
        [radAvr, cellsbin] = correl_radial_avr(cobj(ii), col2avr, col2norm, binsize, limit);
        msg1 = sprintf('2 pt correl dst< %d', limit);
    elseif type==3 && frames(ii)+1 <= length(peaks)
        [radAvr, cellsbin, stdata] = dt_cell_data(cobj(ii),peaks{frames(ii)+1}, col2avr,col2norm,binsize);
        msg1 = sprintf('time deriv, std= %d', stdata);
    else
        fprintf(1, 'unknown data type= %d in plot_radial_avr()\n', type);
    end
    % restrict to radius and be sure enough points in last bin.
    last = ceil(cobj(ii).radius/binsize);
    radAvr = radAvr(1:last);   cellsbin = cellsbin(1:last);
    if cellsbin(end) < mincellsbin
        radAvr(end) = [];  cellsbin(end) = [];
    end
    out(ii).radAvr = radAvr;
    fprintf(1, 'frame=%d, ncells=%d, radius=%d, #cells/bin median=%d, 1st=%d, end=%d\n',...
        frames(ii), cobj(ii).ncells, round(cobj(ii).radius), round(median(cellsbin)), cellsbin(1), cellsbin(end) );
end

% plot pt in middle of bin
cc = colorcube(max(8,nf+1));  % last color is white, <8 uses grey scale
figure,
hold on
for ii = 1:nf
    if isempty(out(ii))
        continue
    end
    avr = out(ii).radAvr;
    xx = binsize*(1:length(avr)) - binsize/2;
    hh(ii) = plot(xx, avr, '.-', 'Color',cc(ii,:), 'MarkerSize',5);
    lgnd{ii} = ['fr=',num2str(frames(ii))];
end
title(sprintf('%s, col2avr, norm=%d %d', [msg0, msg1], col2avr, col2norm) )
xlabel('radius');
legend(hh, lgnd);

% print some parameters for the data.
fields2print = {'forceDonut','donutRadiusMin','donutRadiusMax','gaussFilterRadius',...
    'gaussFilterRadiusEdge'};
for i = 1:length(fields2print)
    ff = fields2print{i};
    try
        fprintf(1, 'userParams.%s= %d\n', ff, userParam.(ff));
    catch
        fprintf(1, 'field= %s not present in userParam\n', ff);
    end
end
return

function plot_cell_traj(cells, peaks, frames)
% plot selected properties for a cluster of cells vs frame, eg rate of
% divergence of cells initially close
%     take cells that exist between frame1 < frame2, where xy is the vector relative
% to cluster center at frame1, and data(ptr, 1:2) = xy. Find all pairs of points
% < limit apart and do a scatter plot of their distance at frame2 vs avr radial
% distance at frame 1

good = [cells.good];
cells(~good) = [];
ncells = length(cells);
inrange = false(ncells,1);
xy = zeros(ncells,2);
ptr = zeros(ncells);

% might do this by picking cell number off peaks array.
fr1 = frames(1);  fr2 = frames(end);
for i = 1:ncells
    if cells(i).onframes(1) <= fr1 && cells(i).onframes(end) >= fr2
        inrange(i) = 1;
        ptr(i) = find(cells(i).onframes==fr1, 1, 'first');
        center = mean(peaks{fr1}(:,1:2) );
        xy(i,:) = cells(i).data(ptr(i), 1:2) - center;
    end
end

plot_scatter(cells(inrange), xy(inrange,:), ptr(inrange), frames(1), frames(end) )

function [radAvr, cellsinbin, stdata] = dt_cell_data(cobj,peaks2, col2avr,col2norm,binsize)
%  supply peaks{} at successive times, and take the difference of
%  col2avr/col2norm, and histogram vs radius
%
[xy, ddata] = dt_data(cobj.data, peaks2, col2avr, col2norm);
stdata = std(ddata);
xy = bsxfun(@minus, xy, cobj.center);
radius1 = sum(xy.^2, 2);
radius1 = sqrt(radius1);
for jj=0:ceil(cobj.radius /binsize)
    indx= radius1 >= binsize*jj & radius1 < binsize*(jj+1);
    radAvr(jj+1) = mean( ddata(indx) );
    cellsinbin(jj+1)=sum(indx);
end
return

%%%%%%%%%%% fns called by top level fns %%%%%%%%%%%%%%%%%%%

function [correl, cellsinbin] = correl_radial_avr(cobj, col2avr, col2norm, binsize, limit)
% compute the subtracted <smad smad> correl for all pairs of points spaced by <
% limit and bin by average radius
%
xy = bsxfun(@minus, cobj.data(:,1:2), cobj.center);
[row, col, dst12] = pair_dst(xy, limit);
if col2norm>0
    smad1 = cobj.data(row, col2avr) ./ cobj.data(row, col2norm);
    smad2 = cobj.data(col, col2avr) ./ cobj.data(col, col2norm);
else
    smad1 = cobj.data(row, col2avr);
    smad2 = cobj.data(col, col2avr);
end
radius12 = sum(xy(row,:) .* xy(row,:) + xy(col,:) .* xy(col,:), 2) ;
radius12 = sqrt(radius12/2);

for jj=0:ceil(cobj.radius /binsize)
    indx= radius12 >= binsize*jj & radius12 < binsize*(jj+1);
    correl(jj+1) = mean( smad1(indx) .* smad2(indx) ) - mean(smad1(indx))*mean(smad2(indx));
    cellsinbin(jj+1)=sum(indx);
end
return

function plot_scatter(cells, xy, ptr, frame1, frame2)
% take cells that exist between frame1 < frame2, where xy is the vector relative
% to cluster center at frame1, and data(ptr, 1:2) = xy. Find all pairs of points
% < limit apart and do a scatter plot of their distance at frame2 vs avr radial
% distance at frame 1

limit = 40;
[row, col, dst] = pair_dst(xy, limit);
dlt = frame2 - frame1;

for n = 1:length(row)
    i = row(n);
    j = col(n);
%     dst0 = dst(n);
    dst1(n) = sum( (cells(i).data(ptr(i)+dlt, 1:2) - cells(j).data(ptr(j)+dlt, 1:2)).^2 );
    dst1(n) = sqrt(dst1(n));
    radius(n) = (sqrt(sum(xy(i,:).^2)) + sqrt(sum(xy(j,:).^2 )))/2;
end
figure,
plot(radius, dst1, '.')
xlabel(['average radius of 2 pts frame= ', num2str(frame1)]);
ylabel(['distance between 2 pts frame= ', num2str(frame2)] );
title(['separation at frame= ',num2str(frame2), ' of 2 pts <= ',num2str(limit),' at frame= ',num2str(frame1)]);
return

function [xy0, ddata] = dt_data(peaks0, peaks1, col1, col2)
% take the time difference bewteen succesive peaks{i}, peaks{i+1} for co11/col2
match = peaks0(:,4);
good  = match>0;
match = match(good);
peaks0 = peaks0(good,:);
xy0 = peaks0(:,1:2);
ddata = peaks1(match,col1) - peaks0(:,col1);
if col2>0
    ddata = (peaks1(match,col1) ./ peaks1(match,col2)) - (peaks0(:,col1) ./ peaks0(:,col2));
end

% 
% function [xy, fdata] = cell_data(peaks, cells, frames)
% % find all cells that exist during the interval frames, and return their xy
% % values, fluorescent data and the cell numbers. 
% % Return cell arrays xy{frames} = xy(ncells,2) etc
% f1 = frames(1);   f2 = frames(end);
% ncells1 = peaks{f1}(:,end);  ncells2 = peaks{f2}(:,end); 
% ncells1 = ncells1(ncells1 > 0);
% if isempty(ncells1)
%     fprintf('missing cell number>0 in column 4 of peaks\n')
%     return
% end
% ncells12 = sort( intersect(ncells1, ncells2) );
% cells = cells(ncells12);
% 
% % need pull data out of cells to get order correct
% dlt = fr2 - fr1;
% nncells = length(cells);
% xy0 = zeros(nncells, 2);
% fdata0 = zeros(nncells, 3);
% ptr = zeros(nncells,1);
% for jj = 1:nncells
%     ptr(jj) = find(cells(jj).onframes == fr1);
% end
% for ii = 0:dlt
%     center = mean(peaks{ii+fr1}(:, 1:2) );
%     for jj = 1:length(cells)
%         xy0(jj,:) = cells(jj).data(ptr(jj)+ii, 1:2) - center;
%         fdata0(jj,:) = cells(jj).fdata(ptr(jj)+ii, 1:3);
%     end
%     xx{ii+1} = xy0;
%     fdata{ii+1} = fdata0;
% end
%%%%%%%%% fn called in several places

function [row, col, dst] = pair_dst(xy, limit)
% for a Nx2 or Nx1 matrix of positions, find all pairs that < limit apart.
% ignore self pairs with dst=0, 

dst = ipdm(xy, 'result','struc', 'subset','maximum', 'limit',limit);
% exclude self distance
self = dst.rowindex==dst.columnindex ;
dst.rowindex(self) = [];
dst.columnindex(self) = [];
dst.distance(self) = [];
row = dst.rowindex;  col = dst.columnindex;  dst = dst.distance;
return