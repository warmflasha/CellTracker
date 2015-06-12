function setUserParamAN20X
%
%
% Contains master set of comments on how to adjust parameters and other
% hints. 8 bit)

global userParam

fprintf(1, '%s called to define params\n',mfilename);

% When verbose=1 set, image of field of cells produced with diagnostics. If
% newFigure=1 these will pile up for successive times and eventually crash MATLAB 
% because of memory limitations. Either run in debug mode and kill by hand or set
% newFigure=0.
userParam.newFigure = 0;

%for single cells vs circular colonies:coltype=1 (uses distance-based colonies
%grouping) coltype=0 uses alphavolume to group circular colonies
userParam.coltype = 1;

%%%%%%%%%%%%%%% used in segmentCells()  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
userParam.verboseSegmentCells = 0;% set to 0, not to print the detailed info on segmentation 


% image smoothing parameters
userParam.gaussRadius=6;% 4 is good for 10x images;6 is ok for 20X
userParam.gaussSigma=1; % 3(gaussThreshSigma is defined below)

%%%%Background parameters
userParam.backgroundSmoothRad=50;
userParam.backgroundSmoothSig=10;  % all three were not in the SetUserParamAN file explicitly
userParam.backgroundOpenRad = 50;

userParam.presubNucBackground=0;%
userParam.presubSmadBackground=0;
userParam.backdiskrad = 200; 

%%%%%%%%%%%%% Parameters for countNuc(): %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Filtering of nuclei done in three steps: 
% 1. An optional threshold on 25llowed min intensity at max.
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
userParam.dontFilterNuc=0; % set to 1 to skip filtering step
userParam.radiusMin = 25; %22
userParam.radiusMax = 39; %37
userParam.minNucSep = 10;%10
userParam.nucIntensityRange = 35;   % value depends on radiusMin/Max 
userParam.nucIntensityLoc   = 150;  % 


%Prior parameters for filtering nuclei based on size/shape, etc from AW
%(Area)
userParam.nucAreaLo =370; % measure the actual values and decide on this parameter
userParam.nucAreaHi = 4500;  % not too big


%%%%%PARAMETER BELOW HERE TYPICALLY DO NOT NEED TO BE MODIFIED%%%%%%%%%%%


%parameters for cytoplasm calculation
userParam.donutRadiusMin = 4;  % 5 must be >=0
userParam.donutRadiusMax = 6;  % 8 set to zero to skip 
userParam.forceDonut = 1; 
userParam.minPtsCytoplasm = 5;%5

%%%%%%%%%%%%%%% Params for gaussThresh() %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Define threshold for grayscale image by fitting gaussian to center of 
% intensity distribution and then calling threshold when actual histogram
% counts is > *Excess * model_fit AND intensity > most probable value + 
% *Sigma * STD(of model fit, ie ignoring points far in + tail). There is
% buried 'verbose' parameter in this routine. Its assumed images are
% integer valued, ie not scaled to [0,1]
userParam.gaussThreshExcess = 6;%6 
userParam.gaussThreshSigma  = 1;%3

userParam.verboseCountNuc = 0;  % to print statistics and an image

% parameter for edge detection. Use 'canny' method in edge() unless get
% nuclei overly large. Check method by on gaussian filtered image 
% edge(red, 'canny') vs edge(red). If loosing nuclei use Canny. Set to zero
% to run default.
userParam.useCanny = 1;%0

userParam.nucSolidity = 0.50; % get rid of funny shapes %0.80
userParam.nucAspectRatio = 2.5; % not too far from circular %3

% define threshold for being in cell by two criterion:
%   percent of nuclear area in cells > percNucInCell  AND
%   area of cells > cyto2NucArea * total_nuc_area
% If get huge area defined as 'cell' decrease percNucInCell to miss a few nuclei
% and get better delineation of cell. Suspect large scale background
% variation in green channel.
userParam.percNucInCell = 0.997;%0.90;
userParam.cyto2NucArea  = 5;%8;

% If use edgeThreshCyto() to define cytoplasm for each nuclei separately,
% do not need previous 2 parameters. Following verbose plots cyto - backgnd
userParam.verboseEdgeThreshCyto = 0;% to suppress printed output 

userParam.sclCytoStd = 1;
