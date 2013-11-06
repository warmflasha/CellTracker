function [maskC, statsN] = segmentCells(red0, gr0)
%
% [maskC, statsN] = segmentCells(red0, gr0)
%
% Input a red nuclear image and a green (cytoplasmic + nuc) image.
% Find nuclei and define a mask for the union of all cells, based on
% thresholding the green.
% If gr0 = [], just find nuclei and quit (maskC is then the nuclear mask)
% The struct array, statsN, has at least the fields,
%   Centroid   xy positions of nuclear centers
%   PixelIdxList  the pixels of the nuclear mask for each nuclei
%
% BUGS?? if running with findNucThresh: need add nuclear mask pixels to
% statsN().PixelIdxList

global userParam;

% add path to subdirectory containing active contour method
% addpath('chen-vese');

%make sure the field userParam.errorstr exists
if ~isfield(userParam,'errorStr')
    userParam.errorStr=[];
end


% if ~(isfield(userParam, 'batch') && userParam.batch) % in batch mode call set in processFolder
%     setUserParamCCC10x(red0);
% end
%
% gauss_r = userParam.gaussFilterRadius;
% hg = fspecial('gaussian', 6*gauss_r, gauss_r);
% red = imfilter(red0, hg, 'replicate');
red = smooth_img(red0, userParam.gaussFilterRadius);
bckgnd = findBackgnd(red, 1);
if ~isempty(gr0)
    for ii=1:size(gr0,3)
        %gr(:,:,ii)  = imfilter(gr0(:,:,ii), hg, 'replicate');
        gr(:,:,ii)  = smooth_img(gr0(:,:,ii), userParam.gaussFilterRadius);
    end
end

thresh1 = 0; thresh2 = 0; info_msg = [];
if userParam.findNucThresh
    % The raw image is better modelled by gaussian than filtered version.
    thresh1 = gaussThresh(red0);
    [maskN1, statsN1] = findNucThresh(red, thresh1);
    info_msg = sprintf('segmentCells(): %d nuc found by findNucThresh, ', length(statsN1));
    %statsN1 = addNucThresh2VPixels(size(red), statsN1);
    %[maskN, statsN] = edge_thresh_nuc(red, statsN1);
    if ~userParam.countNucCtr
        % NB the nuclei as defined by thresh may not be contained in single
        % voronoi polygon.
        maskN  = maskN1;
        % statsN = addVoronoiPolygon2Stats(statsN1, size(red)); % not needed except for verbose.
        statsN = statsN1;
    end
end

if userParam.countNucCtr && ~userParam.findNucThresh
    % impose thresh2 < thresh for findNucThresh since don't want to miss
    % centers, other filters eliminate false +. Could use thresh2 = []
    if (isfield(userParam,'dontFilterNuc') && userParam.dontFilterNuc)
        thresh2 = 0;
    else
        thresh2 = gaussThresh(red);
    end
    
    statsN = countNucCtr(red, thresh2, []);
    info_msg = sprintf('segmentCells(): %d nuc found by countNucCtr, ', length(statsN));
    % add field VPixelIdxList to statsN with pixels for voronoi polygons for
    % each nuclei.
    statsN = addVoronoiPolygon2Stats(statsN, size(red));
    % create the nuclear mask one nuclei at a time, by finding the level with
    % max gradient in intensity, (for this reason need substantial img
    % filtering). Separate the nuclei in mask by restriction to Voronoi.
    % Eliminate nucs that are miss-shaped.
   
    if isfield(userParam,'restrictVoronoi') && userParam.restrictVoronoi
        [junk statsN] = restrict2roi(red, statsN);
    end
    % option to use different filter for edge detection than for countNucCtr()
    if isfield(userParam, 'gaussFilterRadiusEdge') && userParam.gaussFilterRadiusEdge ~= userParam.gaussFilterRadius
        radius = userParam.gaussFilterRadiusEdge;
        [maskN, statsN] = edge_thresh_nuc(smooth_img(red0, radius), statsN, bckgnd);
        info_msg = [info_msg, sprintf('%d nuc after edge_thresh using new gaus filt rad= %d\n\n', length(statsN),radius) ];
    else
        [maskN, statsN] = edge_thresh_nuc(red, statsN, bckgnd);
        info_msg = [info_msg, sprintf('%d nuc after edge_thresh\n\n', length(statsN)) ];
    end
    
end

if userParam.countNucCtr && userParam.findNucThresh
    % impose modest threshold in this case since looking for weak nucs
    thresh2 = gaussThresh(red);
    if (isfield(userParam,'dontFilterNuc') && userParam.dontFilterNuc)
        thresh2 = 0;
    end
    statsN = countNucCtr(red, thresh2, maskN1);
    [maskN, statsN] = simple_mask_from_ctr(red, statsN, bckgnd);
    info_msg = [info_msg, sprintf('%d nuc added by countNucCtr ', length(statsN)) ];
    % following too complex and error prone since edge detection fooled by
    % cutout intensity border.
    %statsN = addVoronoiPolygon2Stats(statsN, size(red));
    %[red_roi, statsN] = restrict2roi(red, statsN);
    %[maskN, statsN] = edge_thresh(red_roi, statsN);
    % now merge two sets of nuc.
    [maskN, statsN] = merge_nuc_sets(maskN1, statsN1, maskN, statsN);
    info_msg = [info_msg, sprintf('%d nuc total\n\n', length(statsN)) ];
end

%%%%%%%%%% done with determination of nuclei
% if no cyto marker, return
if isempty(gr0)
    maskC = maskN;
    return
end

% define cells as nuclei + cytoplasm and find a threshold for cytoplasm
% marker that is as high as possible but contains almost all the nuclear
% pixels.  Could get thresh for each voronoi polygon, one global level
% seems to work ok
%cells = red + gr;
%thresh_c = cell_thresh(cells, maskN);
thresh_c = 0;   %% print later on
% Define cells via threshold.
%maskC = (cells > thresh_c);
%maskC = cleanup_cell_mask(maskC, statsN);

% look at each V-polygon and use either grad(gr) or fraction of max to
% define cyto for each cell. MaskC = mask for cells == cyto + nuclei. Redefine
% the Vpolygons since nuclei have been eliminated since last call
statsN = addVoronoiPolygon2Stats(statsN, size(red));

%Loop over non-nuclear fluoresence channels. run edgeThreshCyto once
% for each
for ii=1:size(gr0,3)
    [maskC(:,:,ii), statsN] = edgeThreshCyto(gr(:,:,ii), statsN, maskN,ii);
end
%cyto mask is 1 if included in any of the individual masks
maskC=any(maskC,3);

% overlay the nuclear, cell and voronoi boundaries on image. NB the two
% color channels stretched to 0-2^16, and possible smoothed images used.
if userParam.verboseSegmentCells
    userParam.errorStr = [userParam.errorStr, sprintf( 'thresh(if>0) used to define nuc: as input= %d, nuc-filtered= %d, thresh for cells= %d\n',...
        round([thresh1, thresh2, thresh_c]) ) ];
    userParam.errorStr = [userParam.errorStr, sprintf( '%s', info_msg)];
    % following did not agree with single call for some data
    %     saturate = 0.01;   % fraction of pixels to saturate in plot
    %     rplot = imadjust(red0, stretchlim(red0, saturate));
    %     gplot = imadjust(gr0,  stretchlim(red0, saturate));
    %     img = cat(3, rplot, gplot, uint16(zeros(size(red0))) );
    
    if userParam.verboseSegmentCells==2
        img = cat(3, imadjust(red0), imadjust(gr0(:,:,1)), uint16(zeros(size(red0))) );
        maskV = true(size(red0));
        maskV( [statsN.VPixelIdxList] ) = 0;
        edges = cat(3, edge_mask(maskN), edge_mask(maskC), maskV );
        pts = stats2xy(statsN);
        if userParam.newFigure
            figure
        end
        showImgEdgePts(img, edges, pts);
        title('segementCell(): img[smoothed?] STRETCHED TO SATURATION, boundaries of nuc(red) cells(gr) and voronoi cells(mag)')
        xlabel('NB green edge drawn after red, thus no red->no cyto, cell==nuc');
        drawnow;
    end
    backgnd = ~imdilate(maskC, strel('square', 7));
    [avr, std1, std2] = backgndNoise(gr0, backgnd);
    %     fprintf(1, 'for gr(cytoplasm) in noncell regions, avr,std= %d %d, std of adjacent pix= %d\n\n',...
    %         round([avr, std1, std2]) );
    
else
    fprintf(1, '%s\n', info_msg);
end

return

%%%%%%%%%%%%%%%%%% end of main %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function img1 = smooth_img(img0, radius)
% apply a gaussian filter to an image
hg = fspecial('gaussian', 6*radius, radius);
img1 = imfilter(img0, hg, 'replicate');
return

function [mask, stats] = edge_thresh_nuc(img, stats, bckgnd)
% given an image, stats of nuclear centers, stats of voronoi polygon and
% label matrix, threshold img in each polygon based on image intensities at
% location of edge pixel values.

global userParam;

% if parameter nonzero, for nuclei with no grad edges, approx by level set,
%   nuc_half_max*(max - bckgnd) + bckgnd
nuc_half_max = 0.5;
%nuc_half_max = 0.; %AW testing, usual value 0.5
if userParam.verboseSegmentCells
    userParam.errorStr = [userParam.errorStr, sprintf( 'segmentCells->edge_thresh_nuc(): if no edges found, define nuc with nuc_half_max= %d\n',...
        nuc_half_max) ];
end

mask = false(size(img));
if isfield(userParam ,'useCanny') && userParam.useCanny
    edges = edge(img, 'canny');
else
    edges = edge(img);
end
nuc_in = length(stats);
xy = stats2xy( stats );

for i = 1:nuc_in
    pixels = stats(i).VPixelIdxList;   %%%statsV(ipt).PixelIdxList;
    ee = edges(pixels);
    % if VPixelIdx is huge area, grads can come from far away from nuc xy and
    % thus level set defined does not guaranteed that nuc xy is within
    % img_px. Should limit region intersected with ee to max nuc area
    % around center
    if sum(ee) > 5
        stats(i).ValidNuc = 1;
        img_ee = img(pixels(ee));
        img_ee=double(img_ee);
        img_mn = min( median(img_ee), img(xy(i,2),xy(i,1)) );
        img_px = img(pixels) >= img_mn;
        mask(pixels(img_px)) = 1;
    elseif nuc_half_max > 0
        stats(i).ValidNuc = 1;
        real_max = max(img(xy(i,2),xy(i,1))-bckgnd, 2);
        img_px = img(pixels) > (nuc_half_max*real_max + bckgnd);
        mask(pixels(img_px)) = 1;
    else
        stats(i).ValidNuc = 0;
        if(userParam.verboseSegmentCells)
            userParam.errorStr = [userParam.errorStr, sprintf( '  WARNING no edges = grad(img) or intensity contrast for nuc= %d, at x,y= %d %d area= %d eliminating\n',...
                i, xy(i,:), length(stats(i).PixelIdxList) ) ];
        end
    end
    if ~mask(xy(i,2), xy(i,1))
        userParam.errorStr = [userParam.errorStr, sprintf( '  WARNING nucleus= %d not in mask, x,y= %d %d\n',...
            i, xy(i,:)) ];
    end
end

% find cc of mask with all img>local edge based threshold and in V-polygons
% eliminate fragements that do not contain a nuc.
version_str = version('-release');
if strcmp(version_str, '2008a')
    [label, num_objects] = bwlabel(mask);
    statsCC = regionprops(label, 'Area','Centroid','Solidity','MajorAxisLength','MinorAxisLength','BoundingBox','PixelIdxList');
else
    cc = bwconncomp(mask);
    label = labelmatrix(cc);
    num_objects = cc.NumObjects;
    statsCC = regionprops(cc, 'Area','Centroid','Solidity','MajorAxisLength','MinorAxisLength','BoundingBox','PixelIdxList');
end
cc_with_nuc = label( sub2ind(size(mask), xy(:,2), xy(:,1) ) );
cc_no_nuc = setdiff( 1:num_objects, cc_with_nuc);
for i = cc_no_nuc
    mask(statsCC(i).PixelIdxList) = 0;
end

% Filter putative nuclei by shape/size criterion and
% overwrite the PixelIdxList field with actual nuc pixels. Can recompute
% mask from [stats.PixelIdxList]
nuc_bad_shape = 0;
too_small = 0;
for i = 1:length(stats)
    ll = label(xy(i,2), xy(i,1)); % can be zero
    if( ~stats(i).ValidNuc )
        continue
    end
    if(ll == 0 && stats(i).ValidNuc) % center of nuc not included in thresholded set. ie Vpolygon threshold off and nuc probably bogus
        if(userParam.verboseSegmentCells)
            userParam.errorStr = [userParam.errorStr, sprintf( '  WARNING segmentCells->edge_thresh_nuc: eliminating nuc= %d, xy= %d %d, centroid not within thresholded level set\n',...
                i, xy(i,:)) ];
        end
        stats(i).ValidNuc = 0;
        continue
    end
    if(ll > 0)
        score = scoreNucShape(statsCC(ll), userParam.verboseSegmentCells, 0);
        if score ~= 1
            stats(i).ValidNuc = 0;
            if score == 0
                too_small = too_small + 1;
            else
                nuc_bad_shape = nuc_bad_shape + 1;
            end
            continue
        end
    end
    stats(i).PixelIdxList = reshape(statsCC(ll).PixelIdxList, 1, []);     % = cc.PixelIdxList{ll}';
end

% eliminate stats with no nuclei
ok = [stats.ValidNuc];
stats = stats(find(ok) );   %% DO NOT OMIT find, get bug otherwise!!
% recompute mask to eliminate invalid nuc from prev loop.
mask = false(size(img));
mask([stats.PixelIdxList]) = 1;

if(userParam.verboseSegmentCells)
    avr_area = round(sum(mask(:))/length(stats) );
    userParam.errorStr = [userParam.errorStr, sprintf( 'In thresh_edge_nuc(): nuclei in= %d nuc out= %d with average area= %d \n  eliminated %d nuc as too small, %d nuc by test\n',...
        nuc_in, length(stats), avr_area, too_small, nuc_bad_shape ) ];
end
return

function thresh = cell_thresh(rg, nuc)
% find a threshold value on red+green image such that high percntage of nuclear mask
% userParam.percNucInCell, falls inside the regions defined by the
% threshold, and in addition the area of the cells > cyto2NucArea*nuc-area

global userParam

nuc_area = sum(nuc(:));
pts_out = nuc_area*(1 - userParam.percNucInCell);
pts_below_thresh = numel(rg) - userParam.cyto2NucArea*nuc_area;
cts_in_nuc = hist(double(rg(nuc)), 0.5:2^16);
cts = hist(double(rg(:)), 0.5:2^16);

in_nuc = 0; thresh1 = 0;
while (in_nuc <= pts_out)
    thresh1 = thresh1 + 1;
    in_nuc = in_nuc + cts_in_nuc(thresh1);
end

thresh = thresh1;
all = 0;  thresh2 = 0;
while all < pts_below_thresh
    thresh2 = thresh2 + 1;
    all    = all + cts(thresh2);
end
thresh = min(thresh1,thresh2);
return

function maskC = cleanup_cell_mask(maskC, statsN)
% Since maskC gotten from threshold, eliminate all conn comp that do not
% contain a nuclear center. Also shrink the mask a bit to compenstate for
% gaussian filter

global userParam

maskC = imerode(maskC, strel('square',round(2*userParam.gaussFilterRadius+1) ) );
cc = bwconncomp(maskC);
label = labelmatrix(cc);
xy = stats2xy(statsN);
cc_withxy = label( sub2ind(size(maskC), xy(:,2), xy(:,1)) );
cc_noxy = setdiff(1:cc.NumObjects, cc_withxy);
for i = cc_noxy
    maskC( cc.PixelIdxList{i} ) = 0;
end

function [mask, stats] = simple_mask_from_ctr(img, stats, bckgnd)
% For a set of nuclear centers defined by stats, cutout a square large
% enough to contain the max nuclei, edge detect and threshold on intensity
% value defined by where the edges fall.

global userParam

radius = ceil( sqrt(userParam.nucAreaHi/pi) );
mask = false(size(img));
xy = stats2xy(stats);

for i = 1:length(xy)
    corner = xy(i,:) - [radius, radius];
    width = (2*radius + 1)*[1,1];
    [cutout, corner, width] = cutout_from_img(img, corner, width);
    if isfield(userParam ,'useCanny') && userParam.useCanny
        edges = edge(cutout, 'canny');
    else
        edges = edge(cutout);
    end
    if sum(edges) > 1
        img_mn = median( cutout(edges) );
    else
        img_mn = 0.5*(stats(i).IntensityCentroid + bckgnd);  % use half max
    end
    [row, col] = find( cutout>img_mn );
    pixels = sub2ind(size(img), row + corner(2) -1, col + corner(1) -1);
    stats(i).PixelIdxList = reshape(pixels, 1, []);
    mask(pixels) = 1;
end


function [mask, stats] = merge_nuc_sets(maskN1, statsN1, maskN2, statsN2)
% add two sets of nuclei, assume the first is primary.

global userParam

maskN2 = maskN2 & ~maskN1;
% besure masks not contiguous and thus would appear connected
maskN2 = imerode(maskN2, strel('square', 3));
mask = maskN1 | maskN2;
cc = bwconncomp(mask);
stats = regionprops(cc, 'PixelIdxList', 'Centroid');

if userParam.verboseSegmentCells
    userParam.errorStr = [userParam.errorStr, sprintf( 'segmentCells(): merged two sets of nuc with %d, %d nuc to yield %d nuc\n',...
        length(statsN1), length(statsN2), cc.NumObjects ) ];
end
return

%%%%%% unused function %%%%%%%%%%%%%%%%
function stats = addNucThresh2VPixels(sizei, stats)
for i = 1:length(stats)
    stats(i).VPixelIdxList = stats(i).PixelIdxList;
end

function stats = dilate_nuc2VPixels(sizei, radius, stats)
% given nuc defined by threshold expand them (but prevent mergers) so as to
% later do gradient edge detection to redefine limits. Store the expanded
% regions in field VPixelIdxList, since this is generic way to limit size
% of cell.

overlap = zeros(sizei);
se = strel('square', round(2*radius + 1));

for cc = 1:length(stats)
    %% need dilate each nuc, find pixels and increment overlap by 1, eliminate all
    % pixels with overlap > 1. A mess
end

function [img, stats] = restrict2roi(img, stats)
% for a set of xy positions retain only those pts in img that are within
% radius of any xy point, set others to zero
global userParam

radius = ceil( sqrt(userParam.nucAreaHi/pi) );
mask = false(size(img));
xy = stats2xy(stats);
for i = 1:length(xy)
    mask(xy(i,2), xy(i,1)) = 1;
end
dst = bwdist(mask);
mask = dst > radius;
img(mask) = 0;

% restrict the voronoi pixels within radius-1 of the centers
mask = ~mask;
mask = imerode(mask, strel('square',3) );
for i = 1:length(stats)
    list = mask(stats(i).VPixelIdxList);
    stats(i).VPixelIdxList = stats(i).VPixelIdxList(list);
end

return