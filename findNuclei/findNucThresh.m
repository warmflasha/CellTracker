function [immask, stats] = findNucThresh(im1, thresh)
%
%   Main function to identify nuclei in intensity image, 
%
%       [immask, stats] = findNucThresh(im1, thresh)
%
%   Does level threshold first
% via call to gaussThresh() and then applies shape criteria to connected
% components. For conn comp that are not to small but an odd shape routine
% tries to decompose them further, either using chen-vese algorithm to
% refine the contour bounding the c.c. and then watershed segmentation of
% intensity image, or just direct watershed (see matlab image anal for
% watershed). Adding the chen-vese step increases time by 2-3x. After
% segmentation all nuclei filtered for shape, and having a unique local 
% intensity max inside.
%   This routine can work with any initial guess for the first mask, though
% I do gaussian filter the image to make the threshold level computation a
% bit more robust and segmentation easier.
%   Note verbose option in userParam to get plots of output and diagnostics
% If problems, suspect the threshold computation has failed, the value used
% in printed under verbose option and user can directly check if reasonable.
%
%   Bugs: may sometimes fail to segment paired nuclei since their mask shape
% passes the nucSolidity and AspectRatio tests, might perform tests on
% intensity image not mask. Chen-vese is fitting a data model of regions of
% contant intensity separated by boundaries (with added noise), which is
% not quite corret for us,but has desired effect of correcting the
% threshold for boundaries, eliminating corners and low intensity bumps.
%   Could improve defn of nucs by refining global threshold with local grads

global userParam

% add path to subdirectory containing active contour method
addpath('chen-vese');

% turn on verbose to see images and print stats. 0 off, 1 on, 2 all details
verbose = userParam.verboseFindNucThresh;

% Two segmentation options, chenvese ~2x slower fits contour to intensity
% image to minimize a combination of variance inside and contour length. 
% Watershed is described in matlab, segments on boundaries between basins
% defined by -intensity.
%   When the edge() fn looks clean, userParam.useEdgeThreshNuc=1 is useful,
% to better define nuclei but unclear how segmentation of cell clusters best
% done ie via an active contour segmentation or connect the edges sort of
% thing.

immask = imfill( im1 > thresh, 'holes');

cc_struct0 = bwconncomp(immask);
num_cc0 = cc_struct0.NumObjects;

if(verbose)
    mask0 = immask;
    userParam.errorStr = [userParam.errorStr, sprintf( 'findNucThresh(): beginning routine with %d conn comp\n',...
        num_cc0) ];
end

if userParam.useEdgeThreshNuc
    stats = regionprops(cc_struct0, 'PixelIdxList', 'Centroid');
    [immask, edges] = edgeThreshNuc(im1, stats, [], verbose); %% NB need Centroid field
    cc_struct0 = bwconncomp(immask);
end
stats = regionprops(cc_struct0, 'Area','Solidity','MajorAxisLength',...
    'MinorAxisLength','BoundingBox', 'PixelIdxList', 'Centroid');

% allow more stringent test on good nuclei, by imposing only 1 local max.
if userParam.test1LocalMax
    stats = add_LocalMax2regionprops(im1, stats);
end

% test the connected components, and either discard, accept, or try to further seg
% to allow parfor loop, need to at least accumulate all changes to immask 
% in separate masks and then apply them at end. Unclear if parfor clever
% enough to realize no successive changes being made in function calls.
% Optional additional filtering prior to segmentation.
num_score2 = 0;
if isfield(userParam, 'segFilterRadius') && userParam.segFilterRadius > 0
    seg_filter = fspecial('gaussian', 6*userParam.segFilterRadius, userParam.segFilterRadius);
else
    seg_filter = [];
end
for i = 1:num_cc0
    score = scoreNucShape(stats(i), verbose, 1);
    % small area discard
    if( score==0 )  
        pixels = cc_struct0.PixelIdxList{i};
        immask(pixels) = 0;
    end
    % area > min, but does not pass test for plausible single nucleus, try
    % to segment. Note no error message unless stats.Centroid exists
    if( score==2 )
        num_score2 = num_score2 + 1;
        if( strcmp(userParam.segmentation, 'chenvese') || strcmp(userParam.segmentation, 'watershed') )
            immask = run_segmentation(im1, immask, stats(i), userParam.segmentation, seg_filter );
        else
            userParam.errorStr = [userParam.errorStr, sprintf('Invalid segmentation method= %s in findNucEDS, choices= watershed or chenvese\n',...
                userParam.segmentation) ];
            fprintf(1, 'Invalid segmentation method= %s in findNucEDS, choices= watershed or chenvese\n',...
                userParam.segmentation);
        end
    end
end

% take previous conn comp as defined in updated immask and test for valid
% nuclei. Discard those that fail test (score != 1)
cc_struct1 = bwconncomp(immask);  % does watershed make wide enough cut for conn=8 to separate??
if(verbose)
    mask1 = immask;
end

stats = regionprops(cc_struct1, 'Area','Solidity','MajorAxisLength',...
    'MinorAxisLength','BoundingBox', 'PixelIdxList', 'Centroid');
% watershed can creates cc with a few pixels
num_cc1 = sum( [stats.Area] > 4 );

if(verbose)
    % errror message comes internally from score_stats for score=2 cases
    userParam.errorStr = [userParam.errorStr, sprintf( 'In findNucThresh(): rejecting putative nuclei by indicated crition...\n')];
end
for i = 1:cc_struct1.NumObjects
    score = scoreNucShape(stats(i), verbose, 0);
    if( score ~= 1 )
        pixels = cc_struct1.PixelIdxList{i};
        immask(pixels) = 0;
    end
end

% final stats with these fields needed by calling program
cc_struct2 = bwconncomp(immask);
stats = regionprops(cc_struct2, 'PixelIdxList', 'Centroid');

% plot smoothed image with dots at centroid of nuclei, and in overlay the 3
% image-masks that resulted from: the level threshold, after segmentation,
% and after final shape/size filter.
if(verbose)
    if userParam.newFigure
        figure, show_img_centers(im1, [stats.Centroid]);
        figure, show_all_masks(mask0, mask1, immask);
    else
        figure(1), show_img_centers(im1, [stats.Centroid]);
        figure(2), show_all_masks(mask0, mask1, immask);
    end
    userParam.errorStr = [userParam.errorStr, sprintf( 'findNucThresh(): num connected components= %d after thresh on level= %d\n',...
        num_cc0, round(thresh) ) ];
    userParam.errorStr = [userParam.errorStr, sprintf( 'conn comp passed to seg(%s)= %d. Total cc after seg= %d, after last filter= %d\n\n',...
        userParam.segmentation, num_score2, num_cc1, cc_struct2.NumObjects) ];
end

return

%%%%%%%%%%%%%%%%%%%%%%% end of main %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stats = add_LocalMax2regionprops(im1, stats)
% for each cc region in stats, find the 'PixelIdxList' of the local max
% contained therein, and the number of disconnected local max

regmx = imregionalmax(im1, 4);
regmx_in_mask = false(size(im1));

for cc = 1:length(stats)
    pixel = stats(cc).PixelIdxList;
    mx = regmx(pixel);
    stats(cc).LocalMaxPixelIdxList = pixel(mx);
    regmx_in_mask(pixel(mx)) = 1;
end

ccregmx = bwlabel(regmx_in_mask) > 0;  % should replace with bcconncomp
for cc = 1:length(stats)
    pixel = stats(cc).PixelIdxList;
    stats(cc).LocalMax = sum(ccregmx(pixel));
end
    
function img_mask = run_segmentation(img, img_mask, stats, method, filter)
% Chen-vese refine edges of mask using gradients of gray scale image. It
% allows for smooth topology changes
% mu weights boundary length, small value eg 0.1 leaves fainter local max
% intact.
%   The watershed, then cuts 'necks'.
   
    corner = floor(stats.BoundingBox(1:2)); % upper left corner, returns [x y] but can be int.5
    width = stats.BoundingBox(3:4) + 2;     % +1 gets exact l-r corner  
    [cut_img, width] = cutout(img, corner, width);

    % define a mask of size cut_img with only the ii-th connected component = 1
    mask1 = false(size(cut_img));
    [aa, bb] = ind2sub(size(img), stats.PixelIdxList);
    pixels = sub2ind(size(cut_img), aa-corner(2)+1, bb-corner(1)+1);
    mask1(pixels) = 1;

    if strcmp(method, 'chenvese')
        mu = 0.1;       % chenvese parameters, lower allows more perimeter vs area
        nsteps = 100;   % do not need run to convergence, just smooth boundaries 
        segmen = chenvese(cut_img, mask1, nsteps, mu, 'chan');
        mask1 = segmen & mask1;
    end
        
%     % use the necks of mask1 to bias the watershed, since can be intensity
%     % ripples in img. Does not work reliably
%     img2 = bwdist(~mask1);
%     min1 = min(cut_img(:));
%     range1 = double(max(cut_img(:)) - min1);
%     range2 = max(img2(:));
%     % equal weights
%     img3 = (range1*img2 + range2*double(cut_img - min1) )/(range1 + range2);
    
    if ~isempty(filter)
        cut_img = imfilter(cut_img, filter, 'replicate');
%         img3 = imfilter(img3, filter, 'replicate');
    end
    
%     figure, imshow(mask1)
%     figure, imshow(watershed_img_with_mask(cut_img, mask1) );
%     figure, imshow(watershed_img_with_mask(img3, mask1) );
    mask1 = watershed_img_with_mask(cut_img, mask1);
    
    % zero out old connected comp and replace with new one
    img_mask(stats.PixelIdxList) = 0;
    [aa, bb] = find(mask1);
    pixels = sub2ind(size(img), aa + corner(2) - 1, bb + corner(1) - 1);   
    img_mask(pixels) = 1;
    return
    
function [cut, width] = cutout(img, corner, width)
% do not extend region beyond image, reset width if necessary
    [row, col] = size(img);
    rows = max(1, corner(2)):min(row, corner(2)+width(2)-1);
    cols = max(1, corner(1)):min(col, corner(1)+width(1)-1);
    cut = img( rows, cols );
    width = [size(cut,2), size(cut,1)];

function show_img_centers(img, centroid)
% for diagnostics, plot nuclei centers on image
    posx = centroid(1:2:end);
    posy = centroid(2:2:end);
    imshow(img,[]);
    hold on;
    plot(posx,posy,'g.');
    hold off;
    title('findNucThresh(): image and centers');
    
function show_all_masks(mask0, mask1, mask2) 
    toshow = double(cat(3, mask0, mask1, mask2));
    imshow( toshow );
    title('findNucThresh(): mask after: thresh, pass1, pass2 as r,g,b')
    
function show_all_edges(im1, mask0, mask1, mask2)
% need to keep class uint16 (or uint8) to make scaling in imshow reasonable.
    im1 = imadjust(uint16(im1));
    mm = max(im1(:));
    edges = mm*uint16(bwperim(mask0)) + im1;
    edges = cat(3, edges, mm*uint16(bwperim(mask1)) + im1 );
    edges = cat(3, edges, mm*uint16(bwperim(mask2)) + im1 );
    figure, imshow(edges);
    title('findNucThresh(): edges after: thresh, pass1, pass2 as r,g,b. (img is rescalled for contrast)') 
    
function show_local_max(img)
    regmx = imregionalmax(img, 4);
    [posy, posx] = find(regmx);
    figure, imshow(img,[]);
    hold on;
    plot(posx,posy,'r.');
    hold off;
    title('image and local max');
    
function mask = watershed_img_with_mask(img, mask)
    
    surface = -double(img);
    pixels = ~mask;
    surface(pixels) = -Inf;
    ll = watershed(surface);
    mask(ll==0) = 0;