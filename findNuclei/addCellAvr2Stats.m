function [maskNonNuc, statsN] = addCellAvr2Stats(maskC, gr, statsN)
%
%   [maskNonNuc, statsN] = addCellAvr2Stats(maskC, gr, statsN)
%
% Union of all cells defined by maskC(ell). Integrate the gr intensity image over
% cytoplasm and nuclei for each cell. 'cytoplasm' is defined as non nuclear
% cell inside the Voronoi polygon corresponding to that nucleus. New fields
% returned in statsN include
%   CytoplasmAvr  CytoplasmStd   CytoplasmArea
%   NuclearAvr    NuclearStd     NuclearArea
%
% if userParam.donutRadiusMax > 0 is set, add 3 new fields
%   DonutAvr  DonutStd   DonutArea
%
% if userParam.forceDonut = 1 makes 'cytoplasm' (for averges) == donut & voronoi.
%   otherwise, statistics of cyto and donut done separately. This is useful
%   when there is no cytoplasm detected.
%
% if userParam.intersectDonutCyto = 1, then limit donut to cytoplasm. This
% operation done once for entire image, hence if a cell has no cyto will
% get no donut
%
% The output array maskNonNuc is either cytoplasm or donut mask or union see
% code below. (depending on forceDonut and donutRadiusMax parameters) This
% array is not used internally, only for output.
%
% Input statsN must have fields Centroid, PixelIdxList, VPixelIdxList. If
% the last one missing, create it.
%

global userParam

min_pts = userParam.minPtsCytoplasm;
verbose = 1;
if verbose
    userParam.errorStr = [userParam.errorStr, sprintf('addCellAvr2Stats(): min pts cyto | nuc= %d\n',...
        min_pts) ];
end
xy = stats2xy(statsN);
if ~isfield(statsN, 'VPixelIdxList')
    statsN = addVoronoiPolygon2Stats(statsN, size(gr));
end

maskN = pixelIdxList2mask(size(maskC), statsN);
maskCyto = maskC & ~maskN;

nImages=size(gr,3);

% define maskNonNuc to be the voronoi intersect cyto, donut or their union depending
% options. maskNonNuc used only for output
if userParam.donutRadiusMax > 0
    donut = bwdist(maskN);
    minr = max(1, userParam.donutRadiusMin); %can not allow minr=0 since would include the nucs)
    donut = (donut <= userParam.donutRadiusMax) & (donut >= minr);
    maskNonNuc = false(size(maskC));
    maskNonNuc([statsN.VPixelIdxList]) = 1;
    if isfield(userParam, 'intersectDonutCyto') && userParam.intersectDonutCyto
        donut = donut & maskCyto;
        maskNonNuc = maskCyto;
    elseif userParam.forceDonut == 1
        maskCyto = donut;
        maskNonNuc = donut & maskNonNuc;  % ie donut intersect voronoi == nonNuc
    else
        maskNonNuc = donut | maskCyto;
    end
else
    maskNonNuc = maskCyto;
end

no_cyto = 0; no_nuc = 0;
for i = 1:size(xy,1)
    % intersect each voronoi with the mask and get pixel lists.
    pts = maskN(statsN(i).VPixelIdxList);
    nuc = statsN(i).VPixelIdxList(pts);
    pts = maskCyto(statsN(i).VPixelIdxList);
    cyto = statsN(i).VPixelIdxList(pts);
    
    statsN(i).CytoplasmArea = length(cyto);
    statsN(i).NuclearArea = length(nuc);
    bckgnd = statsN(i).BackgroundIntensity;
    if userParam.donutRadiusMax > 0
        pts = donut(statsN(i).VPixelIdxList);
        my_donut = statsN(i).VPixelIdxList(pts);
        statsN(i).DonutArea = length(my_donut);
    end
    
    if( length(cyto) < min_pts )
        if verbose
            userParam.errorStr = [userParam.errorStr, sprintf('WARNING too few pts in cytoplasm= %d, cell %d at xy= %d %d nuc-area= %d\n',...
                length(cyto), i, xy(i,:), length(nuc)) ];
        end
        no_cyto = no_cyto + 1;
        statsN(i).CytoplasmAvr = zeros(nImages,1);
        statsN(i).CytoplasmStd = zeros(nImages,1);
    else
        for xx=1:nImages
            currImage=gr(:,:,xx);
            data = double(currImage(cyto) - bckgnd(xx));
            statsN(i).CytoplasmAvr(xx) = round(mean(data));
            statsN(i).CytoplasmStd(xx) = round(std(data));
        end
    end
    
    if userParam.donutRadiusMax > 0 % omit warnings about minimal donuts since generally covered by no_cyto
        if( length(my_donut) < min_pts )
            statsN(i).DonutAvr = zeros(nImages,1);
            statsN(i).DonutStd = zeros(nImages,1);
        else
            for xx=1:nImages
                currImage=gr(:,:,xx);
                data = double(currImage(my_donut) - bckgnd(xx));
                statsN(i).DonutAvr(xx) = round(mean(data));
                statsN(i).DonutStd(xx) = round(std(data));
            end
        end
    end
    
    if( length(nuc) < min_pts )
        if verbose
            userParam.errorStr = [userParam.errorStr, sprintf('WARNING too few pts in nuc= %d, cell %d at xy= %d %d BUG??\n',...
                length(nuc), i, xy(i,:) ) ];
        end
        no_nuc = no_nuc + 1;
        statsN(i).NuclearAvr = 0;
        statsN(i).NuclearStd = 0;
    else
        for xx=1:nImages
            currImage=gr(:,:,xx);
            data = double(currImage(nuc) - bckgnd(xx));
            statsN(i).NuclearAvr(xx) = round(mean(data));
            statsN(i).NuclearStd(xx) = round(std(data));
        end
    end
end
if no_cyto
    userParam.errorStr = [userParam.errorStr, sprintf( 'addCellAvr2Stats(): %d/%d cells with < %d pts in cyto/nuc\n',...
        no_cyto, no_nuc, min_pts) ];
    fprintf(1, 'addCellAvr2Stats(): %d/%d cells with < %d pts in cyto/nuc\n',...
        no_cyto, no_nuc, min_pts);
end

return

% for interactive debugging to go from screen to find closest nuc.
function printxy(xy)
for i = 1:length(xy)
    fprintf(1, 'i= %d xy= %d %d\n,', i, xy(i,:));
end

function mask = pixelIdxList2mask(sizem, stats)
%
mask = false(sizem);
for i = 1:length(stats)
    mask(stats(i).PixelIdxList) = 1;
end


