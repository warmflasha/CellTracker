%% This script calls everything needed to run through a timelapse movie
%  that has been acquired from the SD confocal microscope (Andor) as long
%  as the data is in the correct format (minimal splitting of image files,
%  i.e., only by pos and time)

% I usually will save a version of this script with each dataset, along
% with a version of the userparm.m and trackparam.m files that were used.

%Dataset name: '091516_Wnt3aDoseResponse_LI'

% Brief desc: beta-cat-GFP measured at varied concentrations
% Microscope: Olympus/Andor Spinning Disk Confocal

% Channels:
%   1. 488 - betaCat-GFP   (OvCan)
%   2. 561 - YFP-Smad2 (OvCan)
%   3. not used

% Cell lines used: 
%               (1)ESI017 betaCat-GFP w/ H2B-RFP (piggyback)
%               
%               
%               

% Positions:    
%
%               
%               
%               
%               
% Other:                Wnt3a added at time elapsed = 5:30

%% datset params (set these for each dataset) along with values in accompanying paramfiles
%  You shouldn't have to make changes to anything after this section
%  (besides param files)
data_direc = '901516_Wnt3aDoseResponse_LI_20160915_15630 PM';
file_suffix = '.tif'; % may have to make further adjustments if not using andor .tif files
paramfile = 'setUserParamForOvCan30x1024'; %the paramfile for preprocessing images
trackParam = 'setTrackParamJKM40xOvCans';
positions = 0:23; %positions to run (assumes andor dataset naming conventions)
chan = [2 1]; %first value is nuc channel, following contains other channels
%% set up folder (run inside dataset root directory (one dir up from raw images)
mkdir('Outfiles');
%mkdir('MaxIntensity');
mkdir('scripts&paramfiles');
%% make max intensity projections for masks (via ilastik) and further analysis
% important to save .h5 masks files to have same filename format as the MIP.tif
% files (i.e., 'MAX_Image1.tif' and 'MAX_Image1.h5') You can set up ilastik
% to export masks with this naming convention

%mkMaxIntensities(data_direc,file_suffix); % use these files for segmentation 


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
