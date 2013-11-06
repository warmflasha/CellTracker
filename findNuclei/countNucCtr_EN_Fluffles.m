function valid_stats = countNucCtr(im2, thresh, backgnd)
%
% stats = countNucCtr(im2, thresh, backgnd)
%
% Function to find nuclei centers by looking at local max of smoothed
% intensity image. The local max are filtered to allow a good contrast
% between the intensity at the max and the intensity in a ring surrounding
% the max.
%   Optional inputs: ([] skips)
%   thresh:   all nuclei centers must have intensity > this value
%   backgnd:  exclude all nuc centers in this region.
% Routine eliminates also nuclei with comparison radii outside of img boundary.
%   Output is the stats struct array from regionprops applied to the disconnected
% regions found by bwconncomp().
%
%   KNOWN BUGS: in a smoothed image, two nuclei may seem distinct but not
% separated by saddle in intensity, they do not define two local max only one.

global userParam

% new user parameters introduced here.
%   nucIntensityLoc     used to select provisional local max
%   nucIntensityRange   used to filter local max for actual nuclei according
%   intensity_at_max >= (average intensity in annulus defined by
%   radiusMin/Max) + nucIntensityRange
% nuclei within rmax of boundary of image are excluded.
%   To adjust the two nucIntensity numbers, run with verbose=1 and look at
% the image. If not missing any real nuclei, but many more red dots than
% green the increase nucIntensityLoc. If red dots falling on real nuclei
% then filtering out too many, lower nucIntensityRange.
%
% strel for merging close nuclear centers

strel_nuc = strel('square', floor(1.414*userParam.minNucSep));
use_imreconstruct = 1;
if isempty(thresh)
    thresh = 0;
end

if use_imreconstruct
    mask = im2 + userParam.nucIntensityLoc;
    im3 = imreconstruct(im2, mask);
    regmx = mask - im3;
    % If desired local max separated by saddles at least nucIntensityLoc below
    % max then can further prune false max with following.  Can eliminate a
    % lot of false + by global threshold and eliminate background regions.
    regmx = (regmx >= userParam.nucIntensityLoc - 1);
else
    % regmx = imregionalmax(im2, 4); % used for Dish10x
    regmx = imextendedmax(im2, 5);  % for CCC20x
end
% Group nearby max
regmx = imclose(regmx, strel_nuc );

% eliminate max in predefined background area
if ~isempty(backgnd)
    regmx = regmx & ~backgnd;
end

%regmx = imregionalmax(im2, 4);  % imp to use conn=4
version_str = version('-release');
if strcmp(version_str, '2008a')
    label = bwlabel(regmx);
    stats = regionprops(label, 'PixelIdxList', 'Centroid');
else
    cc_struct = bwconncomp(regmx);
    % most of time in following two calls which are about equally slow.
    stats = regionprops(cc_struct, 'PixelIdxList', 'Centroid');
end
stats = addIntensityShell2Stats(stats, im2);

% filter centroids for intensity contrast. IntensityShell = -1 if shell not
% fully contained in image.

for cc = 1:length(stats)
    avri = stats(cc).IntensityShell + userParam.nucIntensityRange;
    avri = max(avri, thresh);
    if( (stats(cc).IntensityShell >=0) && (stats(cc).IntensityCentroid >= avri) )
        stats(cc).ValidNuc = 1;
    else
        stats(cc).ValidNuc = 0;
        if userParam.verboseCountNuc > 1
            userParam.errorStr = [userParam.errorStr, sprintf( 'rejected nuc x,y= %d %d, img_ctr= %d, img_shell= %d\n',...
                round(stats(cc).Centroid), stats(cc).IntensityCentroid, stats(cc).IntensityShell) ];
        end
    end
end

valid_nuc = find([stats.ValidNuc]) ;  %% do not remove the find
valid_stats = stats(valid_nuc);

if(userParam.verboseCountNuc)
    userParam.errorStr = [userParam.errorStr, sprintf( 'countNucEDS(): found %d local max, %d pass following filters..\n',...
        length(stats), length(valid_stats) )];
    userParam.errorStr = [userParam.errorStr, sprintf( '   intensity at ctr>= %d and exceeds by %d average between radii %d %d\n',...
        round(thresh), userParam.nucIntensityRange, userParam.radiusMin, userParam.radiusMax )];
    pts{1} = stats2xy( stats );
    pts{2} = stats2xy( valid_stats );
    if userParam.verboseCountNuc==2
        if userParam.newFigure
            figure
        end
        showImgEdgePts(im2, [], pts );
        title('countNucCtr(): all local max red, local max passing tests green');
    end
end

return

function stats = addIntensityShell2Stats(stats, img)
% for each of centroid, average the intensity in annulus as defined in userParam.radiusMin,Max.
% For annuli that do not fit within img, set average to unphysical value or
% limit pts depending on removeNucNearBndry flag.
global userParam

[xs, ys] = shell(userParam.radiusMin, userParam.radiusMax);
lim = ceil(userParam.radiusMax);
for cc=1:length(stats);
    x0 = round(stats(cc).Centroid(1)); % centroid can be int+0.5
    y0 = round(stats(cc).Centroid(2));
    stats(cc).IntensityCentroid = img(y0, x0);
    if ~ inrange(x0, y0, lim, size(img))
        if isfield(userParam, 'removeNucNearBndry') && userParam.removeNucNearBndry
            stats(cc).IntensityShell = -1;
            continue
        else
            pixels = limit_pts(size(img), x0+xs, y0+ys);
        end
    else
        pixels = sub2ind(size(img), y0+ys, x0+xs);
    end
    % changed 6/29/11
    % stats(cc).IntensityShell = sum(img(pixels))/length(pixels);
    stats(cc).IntensityShell = round(median(double(img(pixels)))); %BS 120404 added double(. median was giving an error in matlab 2012a
end
return

function [x,y] = shell(rmin, rmax)
% all lattice points x,y within rmin<=r<=rmax of the origin

lim = ceil(rmax);
rmin = rmin^2; rmax = rmax^2;
x = []; y = [];
for i = (-lim):lim
    for j = (-lim):lim
        r = (i*i + j*j);
        if( rmin <= r && r <= rmax )
            x = [x,i];
            y = [y,j];
        end
    end
end


function tf = inrange(x, y, lim, sizei)
% is x,y +- lim within the size of image.
tf = 1;
if( x-lim <1 || y-lim < 1 )
    tf = 0;
    return
end
if( x+lim > sizei(2) || y+lim > sizei(1) )
    tf = 0;
    return;
end

function pixels = limit_pts(sizei, xx, yy)
% limit the pts xx, yy to array dimensions.  Return single index.

out = find(xx < 1);
xx(out) = [];
yy(out) = [];
out = find(xx > sizei(2));
xx(out) = [];
yy(out) = [];
out = find(yy < 1);
xx(out) = [];
yy(out) = [];
out = find(yy > sizei(1));
xx(out) = [];
yy(out) = [];

pixels = sub2ind(sizei, yy, xx);