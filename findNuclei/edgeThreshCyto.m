function [maskC, stats] = edgeThreshCyto(img, stats, maskN,imgNum)
%
%   [maskC, stats] = edgeThreshCyto(img, stats, maskN)
%
% Given an cyto marker, stats-nuclear with V-polygons and nuclear mask,
% find limits of cytoplasm for each nuclei-V-polygon via a local threshold
% based either on gradient of img, or width at half max over backgnd level.
% The std of background used in imposing a meaninful level over background.
%   Must assume the voronoi polygons are disjoint so that level sets found
% for different nuclei give rise to distinct cc.
%
%   maskC = mask for CELLS (cytoplasm + nucleus)
%
%   The field stats(i).BackgroundIntensity = bckgnd added to the stats array
% since the bckgnd can vary within each Vpolygon.
%
%   Three possible background definitions:
% backgndMethod = 2 use pixels with max gradient do define level, each voronoi
%                   (or use fraction of max if no gradient found)
% backgndMethod = 1 use single number for entire image, computed from histogram
% backgndMethod = 0 assume background = lowest 1% of pixel values eg for frog caps,
%
%   Notes: a histogram of non cell pixels (eg imdilate(cellMask, 15) has two
% peaks secondary one ~35% below principal one that comes from PDMS supports in
% image is non fluid regions (no such backgnd in red channel) also ~5-10% bulge
% in intensity center vs edges of cell culture chip.
%   The 'WARNING no cyto detected by grad,...' does not detect 'cyto' that is
% entirely contained in the nucleus, merely that this routine did not find
% anything.
%   TODO more precise calc of stdb0 via cummlative histogram, finding smallest
% std such that 68% of pts lie between [mid-std, mid+std].
%   Also replace max_img with level of top 10% of pts within Vpolygon

global userParam;

verbose = 0;


%This removes background subtraction from this routine, it should be
%handled separately from the image processing
userParam.backgndMethod=-1;
bckgnd0=0; stdb0=0;
cyto_half_max = 0.5;


% use two tests on threshold (1) for pts with gradient when mean is
% compared with something, and (2) when max-img in domain compared. Former
% is less stringent since its mean of many pts
% min_img_in_cyto = bckgnd + userParam.sclCytoStd*stdb;

maskC = false(size(img));

if isfield(userParam ,'useCanny') && userParam.useCanny
    edges = edge(img, 'canny');
else
    edges = edge(img);
end
% exclude gradients in nuclei
edges(maskN) = 0;
% exclude gradients far from nuclei (eg grads from posts, edges of box
rdisk = round(sqrt(userParam.nucAreaHi/pi));
strel0 = strel('square', 2*rdisk+1);
edges( ~imdilate(maskN, strel0) ) = 0;

xy = stats2xy( stats );  %% used for verbose option

nuc_with_edge=0;
bckgnd_list = [];  % incase no nucs in image
for i = 1:length(stats)
    pixels = stats(i).VPixelIdxList;
    max_img = max(img(pixels));
%     if userParam.backgndMethod == 2
%         pts = double(backgndI(pixels));
%         bckgnd = mean(pts);
%         stdb = max(std(pts), stdb0);  %if backgnd defined by imopen may severely reduce variability at cell
%         % bckgnd = min(bckgnd, bckgnd0 + 2*stdb);   % if entire Vpolygon is cell, don't overestimate backgnd
%         bckgnd_list(i) = bckgnd;
%     else
        bckgnd = bckgnd0;
        stdb   = stdb0;
%     end
    stats(i).BackgroundIntensity(imgNum) = round(bckgnd);
    
    ee = edges(pixels);
    thresh1 = 0;  thresh2 = 0;
    sum_ee = sum(ee);
    % case gradient defines a intensity threshold
    if sum_ee > 5
        img_ee = img(pixels(ee));
        thresh1 = mean(img_ee);
        if thresh1 < bckgnd + stdb/sqrt(sum_ee); %reject thresh if not enough above backgnd
            thresh1 = 0;
        else
            nuc_with_edge = nuc_with_edge + 1;  % keep track of number to print diagnostics
        end
    end
    % thresh1 = min(thresh1, bckgnd + 2*stdb); % incase grad wildly off correct level
    
    min_img_in_cyto = bckgnd + userParam.sclCytoStd*stdb;
    if(max_img >= min_img_in_cyto)
        thresh2 = cyto_half_max*(max_img - bckgnd) + bckgnd;
        thresh2 = max( thresh2, min_img_in_cyto);
    end
    thresh(i) = max(thresh1, thresh2);
    
    if verbose
        fprintf(1, 'i= %d xy= %d %d, mx= %d, ee= %d, bck,std= %d %d thresh1,2= %d %d\n',...
            i, xy(i,:), max_img, sum(ee), round([bckgnd, stdb, thresh1, thresh2]));
    end
    
    if thresh(i) > 0
        img_px = img(pixels) > thresh(i);
        maskC(pixels(img_px)) = 1;
    else
        if(verbose)
            fprintf(1, 'WARNING no cyto detected by grad,or level>bckgnd, for nuc= %d, at x,y= %d %d area= %d\n',...
                i, xy(i,:), length(stats(i).PixelIdxList) );
        end
    end
end

% find cc of mask with all img > voronoi-specific threshold regions each
% contained in a single polygon. Eliminate fragements that do not overlap a
% nuc.

%maskC = imfill(maskC, 'holes'); not good if large region with multi-nucl
%called cyto
version_str = version('-release');
if strcmp(version_str, '2008a')
    label = bwlabel(maskC);
    statsCC = regionprops(label, 'PixelIdxList');
else
    cc = bwconncomp(maskC);
    label = labelmatrix(cc);
    statsCC = regionprops(cc, 'PixelIdxList');
end
cc_with_nuc = unique(label(maskN) );
cc_with_nuc = cc_with_nuc( cc_with_nuc>0 );

maskC = false(size(img));
for i = reshape(cc_with_nuc, 1, [])
    maskC(statsCC(i).PixelIdxList) = 1;
end

% print some stats on what was found.
if userParam.backgndMethod == 2
    bckgnd = mean(bckgnd_list);
    stdb    = std(bckgnd_list);
else
    bckgnd = bckgnd0;
    stdb   = stdb0;
end
min_th = unique(thresh);
if(userParam.verboseSegmentCells)
    userParam.errorStr = [userParam.errorStr, sprintf( 'edgeThreshCyto(): no cytoplasm detected for %d/%d nuclei. Thresh set by grad in %d cells \n',...
        sum(thresh==0), length(thresh), nuc_with_edge) ];
    userParam.errorStr = [userParam.errorStr, sprintf( '  Non cell bckgnd,std= %d %d min,mean,max cyto thresh= %d %d %d\n',...
        round([bckgnd, stdb, min_th(2), mean(thresh), max(thresh)]) )];
end
if(userParam.verboseEdgeThreshCyto)
    figure, subplot(1,2,1); imshow(img,[]); title('smoothed cyto image');
    subplot(1,2,2); imshow(img-bckgnd0, []); title('smoothed cyto - backgnd');
end

% add the nuclei back to cytoplasm to get cell mask confined to V polygon
maskC = maskC | maskN;

return

function [bckgnd, std0] = minIntensityBckgnd(img, pct)
%
% define background such that pct (eg ~ 1%) of pixel values are < bckgnd. The
% std is then .5 the range of values spanning  [pct, 2*pct]
maxI = double(max(img(:)));
thresh = pct*numel(img)/100;
[cts, bins] = hist(double(img(:)), maxI);

sum1 = 0;  bckgnd = 0;
for i = 1:maxI
    sum1 = sum1 + cts(i);
    if sum1 > thresh && bckgnd == 0
        bckgnd = bins(i);
    end
    if sum1 > 2*thresh
        std0 = (bins(i) - bckgnd)/2;
        return
    end
end
