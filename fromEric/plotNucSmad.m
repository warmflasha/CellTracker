function plotNucSmad(nuc, img, stats, edges)
%
%   plotNucSmad(nuc, img, stats, edges)
%
% input image file for nuc and smad, and the stats as output from segmentCells
% derived from plotFromMatfile(). Use [] to skip arguments. Will show the
% nuclear outline from segmentCells overlaid on images.

if length(stats)>1 && isfield(stats, 'PixelIdxList')
    nucs = false(size(nuc));
    for i = 1:length(stats)
        nucs(stats(i).PixelIdxList) = 1;
    end
    edges = edge(nucs);
elseif exist('edges', 'var')
    % optional input
else
end

xy = zeros(length(stats),2);
if length(stats)>1 && isfield(stats, 'Centroid')
    for i = 1:length(stats)
        xy(i,:) = round(stats(i).Centroid);
    end
end

figure, imshow(img, []);
hold on
addEdgeCenter(edges,xy)
hold off
title([' smad/IF channel']);

figure, imshow(nuc, []);
hold on
addEdgeCenter(edges,xy)
hold off
title('nuclear signal with edges');
    
return

function addEdgeCenter(edges, xy)

colors = ['r', 'g', 'm', 'y'];

[row, col] = find(edges);
if ~isempty(row)
    plot(col, row, [colors(1) '.'], 'MarkerSize', 1 );
end

if ~isempty(xy)
    plot(xy(:,1), xy(:,2), [colors(1) '.'] )
end
