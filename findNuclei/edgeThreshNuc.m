function [mask, edges] = edgeThreshNuc(img, stats, bckgnd, verbose)
%
%   [mask, edges] = edgeThreshNuc(img, stats, bckgnd, verbose)
%
% given an image and stats struct array with fields
%   Centroid, PixelIdxList (preliminary guess for nuclei or []) and
%   VPixelIdxList a hard bound on region that ith nuc can occupy.
%   (if VPixelIdxList not defined then use PixelIdxList, at least one must be
%   ~empty)
%
% bckgnd = global background, used to assign Nuc area as width at half max when
%   gradients detected in VPixelIdxList.
% bckgnd = [], do not update PixelIdxList when no gradients found in VPixelIdxList
% 
%   Returns mask = all nuclei as logical array. Each cc of mask overlaps with maskin
% but centroids of nuclei in stats may not all be contained in mask., 
%   Returns edges = grad(img) for diagnostics.

global userParam;

% if parameter nonzero, for nuclei with no grad edges, approx by level set,
%   nuc_half_max*(max - bckgnd) + bckgnd
nuc_half_max = 0.5;

% define input mask to filter CC fragments of mask at end.
maskin = false(size(img));
for i = 1:length(stats)
    maskin(stats(i).PixelIdxList) = 1;
end
% define mask to collect newly defined nucs
mask = false(size(img));

if isfield(userParam ,'useCanny') && userParam.useCanny
    edges = edge(img, 'canny');  
else
    edges = edge(img);
end
nuc_in = length(stats);
xy = stats2xy( stats );
nuc_with_ee = 0;

for i = 1:nuc_in
    if isfield(stats, 'VPixelIdxList') && ~isempty(stats(i).VPixelIdxList)
        pixels = stats(i).VPixelIdxList; 
    elseif ~isempty(stats(i).PixelIdxList)
        pixels = stats(i).PixelIdxList;
    else
        pixels = [];
        fprintf(1, 'WARNING edgeThreshNuc(): no VPixelIdxList defined for nuc= %d\n', i);
    end
    ee = edges(pixels);
    % if VPixelIdx is huge area, grads can come from far away from nuc xy and
    % thus level set defined does not guaranteed that nuc xy is within
    % img_px. Should limit region intersected with ee to max nuc area
    % around center
    if sum(ee) > 5  
        stats(i).ValidNuc = 1;
        img_ee = img(pixels(ee));
        img_mn = median(img_ee);
        img_px = img(pixels) > img_mn;
        mask(pixels(img_px)) = 1;
        nuc_with_ee = nuc_with_ee + 1;
    elseif ~isempty(bckgnd)
        stats(i).ValidNuc = 1;
        img_px = img(pixels) > (nuc_half_max*(img(xy(i,2),xy(i,1)) - bckgnd) + bckgnd);
        mask(pixels(img_px)) = 1;
    else
        % if bckgnd = [] accept nuc without edges 
        stats(i).ValidNuc = 1;
        mask(stats(i).PixelIdxList) = 1;
    end
end

% find cc of mask with all img>local_edge based threshold and in V-polygons
% eliminate fragements that do not overlap with input mask.
cc = bwconncomp(mask);
label = labelmatrix(cc);
cc_with_nuc = unique( reshape(label(maskin), 1, []) );
cc_no_nuc = setdiff( 1:cc.NumObjects, cc_with_nuc);
for i = cc_no_nuc
    mask(cc.PixelIdxList{i}) = 0;
end
    
if(verbose)
    fprintf(1, 'edgeThreshNuc(): nuc in= %d, nuc redefined by edge= %d, nuc out(any shape,size)= %d\n',...
        length(stats), nuc_with_ee, cc.NumObjects-length(cc_no_nuc) );
end
return
