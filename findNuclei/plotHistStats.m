function plotHistStats( stats, ii )
%
%   plotHistStats( stats, ii )
%
% quick and dirty plots of data, edit file to change. ii is an int identifying
% time

% want to play with parameters here, so can rerun in editor after stats computed
% once.
min_pts = 5;
min_bckgnd = 0;
max_bckgnd = 34000;

% these are the filters on data points to be plotted. 
% NOTE for the donut data, if computed, use donut area rather than cytoplamic
% area
ok = find( [stats.CytoplasmArea] >= min_pts & [stats.BackgroundIntensity] >= min_bckgnd & [stats.BackgroundIntensity] <= max_bckgnd );
if isfield(stats, 'DonutArea')
    ok_donut = find( [stats.DonutArea] >= min_pts & [stats.BackgroundIntensity] >= min_bckgnd & [stats.BackgroundIntensity] <= max_bckgnd );
end

cyto_avr = [stats.CytoplasmAvr];
nuc_avr  = [stats.NuclearAvr];
cyto_std = [stats.CytoplasmStd];
nuc_std  = [stats.NuclearStd];
cyto_area = [stats.CytoplasmArea];
nuc_area  = [stats.NuclearArea];
cell_bckgnd = [stats.BackgroundIntensity];

cyto_avr = double(cyto_avr(ok));
nuc_avr  = double(nuc_avr(ok));
cyto_std = double(cyto_std(ok));
nuc_std  = double(nuc_std(ok));
nuc_area = double(nuc_area(ok));
cyto_area = double(cyto_area(ok));
cell_bckgnd = double(cell_bckgnd(ok));

nuc2cyto = nuc_avr ./ cyto_avr;

fprintf(1, 'plotHistStats(): found %d cells out of %d passing all filters: pts_cyto>= %d, bcngnd>= %d, bckgnd<= %d\n',...
    length(nuc_avr), length(stats), min_pts, min_bckgnd, max_bckgnd );

figure
subplot(3,2,1); hist(cyto_avr, 10), title(['cytoplasm average ii=', num2str(ii)]);
subplot(3,2,2); hist(nuc_avr, 10), title('nuclear average');
subplot(3,2,3); plot(cyto_avr, nuc_avr, '.'), title(['nuc(y) vs cyto(x) average ii=', num2str(ii)]);
%%figure, plot(cyto_area, cyto_avr, '.'), title('cyto avr vs area'); 
subplot(3,2,4); plot(cyto_avr, cyto_std, '.'), title('cyto std vs avr');

subplot(3,2,5); hist(nuc2cyto, 10), title('nuc-avr / cyto-avr');
subplot(3,2,6); plot(cell_bckgnd, cyto_avr, 'g.', cell_bckgnd, nuc_avr,'r.'), title('cyto(g) nuc(r) avr vs backgnd');

if isfield(stats, 'DonutArea')
    donut_avr = [stats.DonutAvr];
    donut_avr = max( double(donut_avr(ok_donut)), 1);
    donut_std = [stats.DonutStd];
    donut_std = double(donut_std(ok_donut) );
    nuc_avr = [stats.NuclearAvr];
    nuc_avr = double(nuc_avr(ok_donut) );
    nuc2donut = nuc_avr ./ donut_avr; 
    
    fprintf(1, 'plotHistStats(): donut stats plotting %d cells out of %d with pts_donut>= %d\n',...
        length(ok_donut), length(stats), min_pts );

    
    figure
    subplot(2,2,1); hist(donut_avr, 10), title(['donut average ii=', num2str(ii)]);
    subplot(2,2,2); plot(donut_avr, nuc_avr, '.'), title(['nuc(y) vs donut(x) average ii=', num2str(ii)]);
    subplot(2,2,3); hist(nuc2donut, 10), title(['nuc-avr / donut-avr ii=', num2str(ii)]);
    subplot(2,2,4); plot(donut_avr, donut_std, '.'), title('donut std vs avr');
end

return
