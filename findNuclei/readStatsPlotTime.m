function readStatsPlotTime(folder, stats_file)
%
%   readStatsPlotTime(folder, stats_file)
%
%   Quick and dirty routine to read the stats file for all the processed times
% and plot time courses. Code copied from processFolderRedGr(). currently assume folder = [].
%   Edit end of process1stats() function below to select which field to plot.
%
    if ~isempty(folder)
        [logfile, path, yymmdd, chnum] = getLogfile(folder);
        if exist(logfile, 'file')
            feedings = getFeedings(logfile, chnum, 0);
        else
            fprintf(1, 'can not find feeding logfile on path to folder= %s\n', folder);
            feedings = [];
        end
    end

    stats = load(stats_file, 'stats');
    stats = stats.stats;
    
    for ii = 1:length(stats) 
        statsN = stats(ii).statsN;

%         nameG = listG(ii+1).name;   
%         nameG = [folder, filesep, nameG];
%         imgG = imread(nameG);
%         dateG = datestr( listG(ii+1).datenum);
%         
%         nameR = listR(ii+1).name;  
%         nameR = [folder, filesep, nameR];
%         imgR = imread(nameR);
%         dateR = datestr( listR(ii+1).datenum);
%         
%         fprintf(1, '\ntime red,gr images= %s %s, feeding history..\n', dateR, dateG);
%         feedingHistory(feedings, listG(ii+1).datenum );
        if isempty(statsN)
            continue
        end
        out(ii) = process1stats(statsN);
        % plotHistStats( statsN, ii);
        
    end
    i1 = find(out>0, 1, 'first');
    len = length(out);
    figure, plot(i1:len, out(i1:end)), title(stats_file)
    
    return

function out = process1stats(stats)

    min_pts = 5;
    min_bckgnd = 0;
    max_bckgnd = 34000;

    ok = find( [stats.CytoplasmArea] >= min_pts & [stats.BackgroundIntensity] >= min_bckgnd & [stats.BackgroundIntensity] <= max_bckgnd );
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

%     fprintf(1, 'plotHistStats(): found %d cells out of %d passing filters: pts_cyto>= %d, bcngnd>= %d, bckgnd<= %d\n',...
%         length(nuc_avr), length(stats), min_pts, min_bckgnd, max_bckgnd );

    if isfield(stats, 'DonutArea')
        donut_avr = [stats.DonutAvr];
        donut_avr = double(donut_avr(ok) );
        donut_std = [stats.DonutStd];
        donut_std = double(donut_std(ok) );
        nuc2donut = nuc_avr ./ donut_avr;   % note can be 1/0, 
        nuc2donut = nuc2donut( find(nuc2donut < 3));
    end
    
    out = median(nuc2donut);
    % out = mean(nuc2donut);
    % out = mean(nuc2cyto);