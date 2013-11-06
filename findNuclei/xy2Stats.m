function xy2Stats(x0, y0, stats)
%
% xy2Stats(x0, y0, stats)
%
% read in a particular x0 y0, print properties of closest nucleus as
% obtained from the stats struct array.

xy = stats2xy(stats);
dst = abs(xy(:,1) - x0) + abs(xy(:,2) - y0);
[mn, ii] = min(dst);
i = ii(1);
fprintf(1, 'nuc= %d at xy= %d %d, area= %d\n', i, xy(i,:), length(stats(i).PixelIdxList) );
if ~isfield(stats, 'NuclearAvr')
    return
end
fprintf(1, 'nucl avr,std= %d %d', stats(i).NuclearAvr, stats(i).NuclearStd);
if isfield(stats, 'CytoplasmAvr')
    fprintf(1, ' cytoplasm avr,std= %d %d, pts= %d\n',...
        stats(i).CytoplasmAvr, stats(i).CytoplasmStd, stats(i).CytoplasmArea);
else
    fprintf(1, '\n');
end

return