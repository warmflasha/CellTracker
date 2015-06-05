function varargout = InitializeSpotRecognitionParameterstest(p,n_frame,channel,spot_folder, z1)
% initialize spot recogntion parameters. 
% usage example:
%   sr = InitializeSpotRecognitionParameters(p,n_frame,channel,outputfolder)
% inputs:
%     p            = varargin{1}; % structure array containing
%     n_frame      = varargin{2};
%     channel      = varargin{3};
%     outputfolder = varargin{4};
% outputs:
%     varargout{1} = sr;

% check number of input and output arguments
% error(nargchk(5,5,nargin));
% error(nargchk(1,1,nargout));
% 
% p            = varargin{1};
% n_frame      = varargin{2};
% channel      = varargin{3};
% outputfolder = varargin{4};
% z = vargin{5};
z = z1(1)-1;
outputfolder = spot_folder;

%% IMAGE PARAMETERS

img_name = sprintf('/images%02d/', channel);
% %%sr.image.fullname            = [p.exp.path '/images02/' p.image.base_name ...
%                                 num2str(p.exp.frm2spl(n_frame),'%01d') ...
%                                '_f' num2str(p.exp.frm2img(n_frame),'%04d')];  % image name

sr.image.fullname            = [p.exp.path img_name p.image.base_name ...
                                num2str(p.exp.frm2spl(n_frame),'%01d') ...
                               '_f' num2str(p.exp.frm2img(n_frame),'%04d')];
sr.image.zrange              = 0:z;                                  % number of Z-stacks in the image
sr.image.channel             = channel;                              % channel number of the image to analyze
sr.image.frame               = n_frame;
sr.image.total_frames        = p.exp.totalframes;

%% SEGMENTATION MASK PARAMETERS

sr.seg.dir                   = p.seg.dir;                            % directory containing the segmentation masks
sr.seg.name                  = [p.seg.base_name num2str(n_frame,'%02d') '.mat'];   % name of the mat file containing the segmented mask. The mask variable name should be 'LcFull'
sr.seg.thicken_radius        = 3;                                    % radius of strel used to dilate cell masks
sr.seg.multiz_mask           = false;                                % whether each z has its own segmentation mask

%% SPOT RECOGNITION PARAMETERS
sr.spotrec.gf.size           = 3;                                    % strel size used to apply gaussian low pass filter
sr.spotrec.gf.sigma          = 1;                                    % sigma of gaussian ditribution (pixels)
sr.spotrec.peak.connectivity = 8;                                    % local conectivity used to assess peaks
sr.spotrec.peak.threshold    = 700;                                  % threshold to consider something a peak
sr.spotrec.discard_spots     = true;                                 % use or not spots from outside cells
sr.spotrec.output            = [ outputfolder '/spotrec/'];

%% Z STACK PEAK MATCHING
sr.zstack.max_spot_dist      = 2.5;                                  % maximum allowed distance (in pixels) between the peaks of two slides to consider them as the same spot
sr.zstack.min_slide_number   = 2;                                    % minimum number of slides where a spot needs to appear to be considered real
sr.zstack.check_results      = false;                                % whether or not check the results

%% FITTING PROCEDURE
sr.fit.save.maxima_image     = true;                                 % save image with the maxima
sr.fit.display.maxima_data   = false;                                % display spot measurements (peak and integrated intensity, background and area) in output image
sr.fit.save.maxima_fit       = true;                                 % save fit data for each spot?
sr.fit.box                   = 5;                                    % radius (in pixels) of the initial area to used to fit a spot
sr.fit.lambda                = 680;                                  % emission wavelenght of the experiment

% if sr.image.frame <3
%     sr.fit.NA                    = 1.35;                                  % numerical apperture of the microscope
%     sr.fit.pixel_size            = 16e3/(60*2.5);                       % pixel size in nm;  16e3 nm = pixel pitch of CCD;  100*2.5 = total magnification
% else
%     sr.fit.NA = 0.75;
%     sr.fit.pixel_size = 16e3/20*2.5;
% end


sr.fit.NA = 1.35;
sr.fit.pixel_size = 16e3/(60*2.5);
    

sr.fit.cell_info             = true;                                 % calculate relative positions of spots inside the cell
sr.fit.output                = [ outputfolder '/fit/' ];

%% OUTPUT FOR DATA
sr.output                        = [ outputfolder '/data/' ];

% Create a folder to save figures for each fitting process
if ~exist(outputfolder,'dir'), mkdir(outputfolder); end
if ~exist(sr.spotrec.output,'dir'), mkdir(sr.spotrec.output); end
if ~exist(sr.fit.output,'dir'), mkdir(sr.fit.output); end
if ~exist(sr.output,'dir'), mkdir(sr.output); end

varargout{1} = sr;

return




