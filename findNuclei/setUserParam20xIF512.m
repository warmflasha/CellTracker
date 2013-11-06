function setUserParamCCC20x(img)
%
%   setUserParamsCCC20x(img)
%
% Contains master set of comments on how to adjust parameters and other
% hints. Parameters based on 110118 images. The argument img is used only
% to extract dimensions, and decrease all parameters in pixel units by 2 if
% image is 512
%
% Note on file compression: to go from 1024x1344 1.6mb .png to ~110kb
% 512x672, mask both nuc and cyto images with dilation of the total cell
% mask (ie set to ==0 pixels outside of the mask) and 
% then save as imwrite(... 'name.jpeg', 'Bitdepth', 16) and use default 
% compression. (might try setting backgnd to min(img) and using 8 bit)

global userParam

rescale = 1;
if (min(size(img)) >= 512) && min(size(img)) < 1024
    rescale = 0.5;
end

fprintf(1, 'setUserParamCCC20x(): called to define params\n');

%%%%%%%%%%%%%%% used in segmentCells()  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
userParam.verboseSegmentCells = 1;

% use at least one of these methods to find nuclei. 
%   findNucThresh() thresholds on a global intensity value determined via
% gauss_thresh(), and then tries to segment composite nuclei. Can miss
% faint nuclei, but these picked up by subsequent call to countNucCtr. If
% nuclei overly large, increase params for gaussian_thresh() below.
%   countNucCtr() begins by finding all local max intensity and then
% expands each by looking at contour height of max intensity gradient. Can
% fail to separate nuclei without clear saddle in intensity inbetween, but
% the size of nuclei that are segmented looks very good.
userParam.findNucThresh = 0;
userParam.countNucCtr   = 1;

% filter all 1024x1300 sized images with this gaussian filter to give clean
% local max, and edge detection, 2 will not work
userParam.gaussFilterRadius = 4*rescale;

% parameter for edge detection. Use 'canny' method in edge() unless get
% nuclei overly large. Check method by on gaussian filtered image 
% edge(red, 'canny') vs edge(red). If loosing nuclei use Canny. Set to zero
% to run default.
userParam.useCanny = 1;

% define threshold for being in cell by two criterion:
%   percent of nuclear area in cells > percNucInCell  AND
%   area of cells > cyto2NucArea * total_nuc_area
% If get huge area defined as 'cell' decrease percNucInCell to miss a few nuclei
% and get better delineation of cell. Suspect large scale background
% variation in green channel.
userParam.percNucInCell = 0.997;
userParam.cyto2NucArea  = 5;

% If use edgeThreshCyto() to define cytoplasm for each nuclei separately,
% do not need previous 2 parameters. 
%   Algorithm looks for gradient of smoothed green, chose a threshold of median
% intensity of points where a gradient is detected.
% or if no gradients AND the max green in V-poly is
% > bckgnd + sclCytoStd*stdb (ie background + some mulitple of std of backgnd)
% then define threshold =  cytoHalfMax*(max_img_Vpoly - bckgnd) + bckgnd
%   The background can either be defined locally for each Vpoly as imopen(img, big-box)) or as 
% one number for entire image. Std can be computed locally but always >= std for entire image 
userParam.sclCytoStd = 1;
userParam.cytoHalfMax = 0.5;
userParam.localBackgnd = 1;

% nucAreaHi used here also but defined below with similar params.

%%%%%%%%%%%%% Parameters for countNuc(): %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Used imreconstruct method to find all local max and then filter.
% regmx = imextendedmax(im2, 5) worked somewhat, but gave more false pos.

userParam.verboseCountNuc = 1;  % to print statistics and an image
userParam.V2008a = 0;       % set =1 with old versions of matlab lacking bwconncomp.m

%   Filtering of nuclei done in three steps: 
% 1. An optional threshold on allowed min intensity at max.
% 2. A generous test for local max, that should not miss anything and
% also give not too many false +.  This is done by imreconstruction
% comparing mask = img + nucIntensityLoc, with dilation of img. Increase
% the nucIntensity local parameter to eliminate false +, decrease if
% missing real nuclei. All local max within a distance of minNucSep are
% merged.
% 3. A filter compares intensity at centroid of each local max with
% intensity in ring defined by radiusMin/Max and demands a contrast of at
% least nucIntensityRange. If loosing real nucs, decrease, if getting false
% positives, increase.
%   To adjust the two nucIntensity numbers, run with verbose=1 and look at
% the image. The nuclei after first and second selection shown in different
% colors. If not finding at all obvious nucl, lower thresh in (1)
%
userParam.radiusMin = 9; 
userParam.radiusMax = 10;
userParam.minNucSep = 6;
if rescale < 1
    userParam.radiusMin = 5; 
    userParam.radiusMax = 6;
    userParam.minNucSep = 3;
end
userParam.nucIntensityRange = 10;   % value depends on radiusMin/Max 
userParam.nucIntensityLoc   = 10;  

%%%%%%%%%%%%%% Parameters for findNucThresh()  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

userParam.verboseFindNucThresh = 1;

% The segmentation method. Watershed is >3x quicker, but needs well defined
% necks in the binary image gotten via thresholding. chenvese will try to
% find the max gradient contour, but can eliminate nuclei of very different
% intensities within same connectec component.
%userParam.segmentation = 'chenvese';
userParam.segmentation = 'watershed';

%Prior parameters for filtering nuclei based on size/shape, etc from AW
userParam.nucAreaLo =100*rescale^2; 
userParam.nucAreaHi = 2600*rescale^2;  % not too big
userParam.nucSolidity = 0.50; % get rid of funny shapes
userParam.nucAspectRatio = 2.5; % not too far from circular

%%%%%%%%%%%%%%% Params for gaussThresh() %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Define threshold for grayscale image by fitting gaussian to center of 
% intensity distribution and then calling threshold when actual histogram
% counts is > *Excess * model_fit AND intensity > most probable value + 
% *Sigma * STD(of model fit, ie ignoring points far in + tail). There is
% buried 'verbose' parameter in this routine. Its assumeed images are
% integer valued, ie not scaled to [0,1]
userParam.gaussThreshExcess = 5;
userParam.gaussThreshSigma  = 3;