function [maskN, statsN] = getNuclearMaskNoIlastik(red)

global userParam;

bckgnd = findBackgnd(red, 1);

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
    [~, statsN] = restrict2roi(red, statsN);
end
%     % option to use different filter for edge detection than for countNucCtr()
%     if isfield(userParam, 'gaussFilterRadiusEdge') && userParam.gaussFilterRadiusEdge ~= userParam.gaussFilterRadius
%         radius = userParam.gaussFilterRadiusEdge;
%         [maskN, statsN] = edge_thresh_nuc(smooth_img(red0, radius), statsN, bckgnd);
%         info_msg = [info_msg, sprintf('%d nuc after edge_thresh using new gaus filt rad= %d\n\n', length(statsN),radius) ];
%     else
[maskN, statsN] = edge_thresh_nuc(red, statsN, bckgnd);
info_msg = [info_msg, sprintf('%d nuc after edge_thresh\n\n', length(statsN)) ];

userParam.errorStr = [userParam.errorStr, sprintf( '%s', info_msg)];

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
end

function [mask, stats] = edge_thresh_nuc(img, stats, bckgnd)
% given an image, stats of nuclear centers, stats of voronoi polygon and
% label matrix, threshold img in each polygon based on image intensities at
% location of edge pixel values.

global userParam;

% if parameter nonzero, for nuclei with no grad edges, approx by level set,
%   nuc_half_max*(max - bckgnd) + bckgnd
nuc_half_max = 0.5;
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
cc = bwconncomp(mask);
label = labelmatrix(cc);
num_objects = cc.NumObjects;
statsCC = regionprops(cc, 'Area','Centroid','Solidity','MajorAxisLength','MinorAxisLength','BoundingBox','PixelIdxList');
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
end

