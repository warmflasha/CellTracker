function runKeep1Colony(matfile)
% 
%   runKeep1Colony(matfile)
%
% Routine to take a matfile output by runSegmentCells and eliminate all nuclei
% that are not in the the largest colony. The largest colony is found by
% dilating all the nuclei centers and finding the largest connected component.
% Its convex hull then defines the unique colony. If center of image not in
% largest colony then a warning printed. This can be due to a sparse colony for which
% the dilate and fill leaves channels.
%
%   On output:
% Saves a new matfile under the name new_matfile in the CWD, 
% with the mat.peaks and mat.statsArray trimmed of nuclei outside of colony
% Also new fields center, and radius added to imgfiles
% for each time. (Note can not add this info to either peaks{} or statsArray{}
% which are both struct arrays.).
%
%   There is optional graphics fn, for checking what was done, that is
% controlled by verbose option

verbose = 0;
mat = load(matfile);
frames = length(mat.peaks);
fprintf(1, 'runKeep1Colony(): read matfile= %s with %d frames. Selecting largest colony. Adding radius,center to imgfiles()\n',...
    matfile, frames);
for ii = 1:frames
    peaks = mat.peaks{ii};
    nnucs = size(peaks, 1);
    imgsize = mat.imgfiles(ii).size;
    mask = false(imgsize);
    % mark nuclei
    indx = sub2ind(imgsize, peaks(:,2), peaks(:,1));
    mask(indx) = 1;
    nucarea = mean(peaks(:,3));
    diameter = 2*ceil(sqrt(nucarea/pi));
    mask = imdilate(mask, strel('disk', diameter));
    mask = imfill(mask, 'holes');
    [label, nlabel] = bwlabel(mask);
    stats = regionprops(label, 'ConvexArea', 'ConvexHull', 'Centroid');
    label00 = label(round(imgsize(1)/2), round(imgsize(2)/2));
    [max_area, label_mx] = max( [stats.ConvexArea] );
    
    % center of image is not in conn component of dilated cell nuclei
    if label00 == 0 
        fprintf(1, 'frame= %d, center in background, using colony with max area= %d, centroid= %d %d\n',...
            ii, stats(label_mx).ConvexArea, round(stats(label_mx).Centroid) );
    end
    if label00 && label00 ~= label_mx
        fprintf(1, 'frame= %d, colony containing center does not have largest area %d vs %d, keeping largest area\n',...
            ii, stats(label00).ConvexArea, max_area );
    end
    
    xy = stats(label_mx).ConvexHull;
    mask = poly2mask(xy(:,1), xy(:,2), imgsize(1), imgsize(2));
    good = mask(indx);
    peaks(~good,:) = [];
    peaksin = mat.peaks{ii};  % used for graphing only
    mat.peaks{ii} = peaks;
    mat.statsArray{ii}(~good,:) = [];
    %find center, radius by fitting exterior points to a circle
    edgeInds=convhull(peaks(:,1),peaks(:,2));    
    [xc yc rad] = circfit(peaks(edgeInds,1),peaks(edgeInds,2));
    center = round([xc yc]);  radius = round(rad + diameter/2);
    mat.imgfiles(ii).center = center; 
    mat.imgfiles(ii).radius = radius;
    %stats( [stats.ConvexArea] < min_convex_area ) = [];
    fprintf(1, 'frame= %d, found %d clumps #nucl in colony= %d, out= %d, ctr= %d %d, radius= %d\n',...
        ii, length(stats), nnucs, size(peaks,1), center, radius);
    
    if verbose
        plotNucColony(imgsize, peaksin, peaks, center, radius);
        title(['frame= ', num2str(ii),' Nuclei in colony (g), excluded (r) and colony limits (c)']);
    end
end

[junk, matfile, junk] = fileparts(matfile);
new_mat = ['new_', matfile];
save(new_mat, '-struct', 'mat');
fprintf(1, 'output new matfile= %s in CWD with nuclei restricted to 1 colony\n', new_mat);

function plotNucColony(imgsize, peaksin, peaksout, center, radius)
mask = false(imgsize);
imshow(mask)
hold on
plot(peaksin(:,1), peaksin(:,2), '.r');
plot(peaksout(:,1), peaksout(:,2), '.g');
drawcircle(center, radius, 'c');
hold off