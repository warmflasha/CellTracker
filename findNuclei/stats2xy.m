function xy = stats2xy(stats)
% take [stats.Centroid] and reformat into xy(:,2)
centroid = round([stats.Centroid]);
if isempty(centroid)
    xy = [];
    return
end
xy(:,1) = centroid(1:2:end);
xy(:,2) = centroid(2:2:end);