%% This script calls everything needed to run through a timelapse movie
%  that has been acquired from the SD confocal microscope (Andor) as long
%  as the data is in the correct format (minimal splitting of image files,
%  i.e., only by pos and time)

% I susually will save a version of this script with each dataset, along
% with a version of the userparm.m and trackparam.m files that were used.

%Dataset name: '082416_NFKB_OVCAN_MediaTransfer'

% Brief desc: RelA-YFP measured with media transfer to test hypothesis that
% adaptive response is due to degradation of TNFa in media
% Uses masks from ilastik to segment ovcan and nof timelapse movie

% Microscope: Olympus/Andor Spinning Disk Confocal

% Channels:
%   1. 515 - YFP-Smad2 (OvCan)
%   2. 445 - CFP-H2B   (OvCan)
%   3. not used

% Cell lines used: 
%               (1) OVCA433 CFP-H3B, YFP-Smad2  [Human ovarian adenocarcinoma] (OvCan)
%               
%               
%               

% Positions:    20 total
%
%               0-9          TNFa added at t = 2ish hours?? (consult notes)
%               10-19        media from pos 0-9 transfered to these positions at
%                            t= 20ish hours??

% Other:

%% datset params (set these for each dataset) along with values in accompanying paramfiles
%  You shouldn't have to make changes to anything after this section
%  (besides param files)
data_direc = '082416_NFKB_OVCAN_MediaTransfer_20160826_84546 AM';
file_suffix = '.tif'; % may have to make further adjustments if not using andor .tif files
paramfile = 'setUserParamForOvCan30x1024'; %the paramfile for preprocessing images
trackParam = 'setTrackParamJKM40xOvCans';
positions = 0:19; %positions to run (assumes andor dataset naming conventions)
chan = [2 1]; %first value is nuc channel, following contains other channels
%% set up folder (run inside dataset root directory (one dir up from raw images)
mkdir('Outfiles');
mkdir('MaxIntensity');
mkdir('scripts&paramfiles');
%% make max intensity projections for masks (via ilastik) and further analysis
% important to save .h5 masks files to have same filename format as the MIP.tif
% files (i.e., 'MAX_Image1.tif' and 'MAX_Image1.h5') You can set up ilastik
% to export masks with this naming convention
mkMaxIntensities(data_direc,file_suffix); % use these files for segmentation 
%                                              in ilastik before moving forward
%% read in ilastik masks and run segmentation
direc = 'MaxIntensity';
    parfor pos = positions;
    outfile = fullfile('Outfiles',['pos' int2str(pos) '.mat']);
    runSegmentCellsAndorSplitOnlyByPosTime(direc,pos,chan,paramfile,outfile);
    end
copyfile(which(paramfile),['scripts&paramfiles/UserParamCopy.m']); %saves userParam with dataset
disp('Images and masks processed');
mkdir('OutfileBackups');
copyfile('Outfiles','OutfileBackups');
disp('data backed up in /OutfileBackups');


%% run tracker
disp('attempting to track cells...');
parfor pos = positions;
    runTracker(['Outfiles' filesep 'pos' int2str(pos) '.mat'],trackParam);
end
copyfile(which(trackParam),['scripts&paramfiles/TrackParamCopy.m']); %saves trackParam with dataset
disp('Tracking complete');
