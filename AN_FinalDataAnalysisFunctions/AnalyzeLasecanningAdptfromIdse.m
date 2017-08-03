clear all; %close all;
% addpath(genpath('/Users/idse/repos/Warmflash/stemcells')); 
% dataDir = '/Users/idse/data_tmp/160812_C2C12siRNASki+Skil';
%projdata =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2017-01-10-BMP4woSB/nuc/MIP');
%dataDir = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2017-01-10-BMP4woSB/nuc2/MIP';%'/Volumes/Seagate Backup Plus Drive/RICE_Research_databackup/BMPwoSB_12hr_20170109_94617 AM';
%dataDir = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2017-02-10-BMP4wellwithSB39hrs';% saved the projections and ilastic output in a diff. dir

dataDir = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2017-05-24-GFPsmad4InitialSignalingTest';

ff = readAndorDirectory(dataDir);
 %meta = MetadataAndor(dataDir);
% manual metadata
%-------------------4
% TODO : modify MetadataAndor to contain all info below

% returned by MetadataAndor on good directory
% for Laser Scanning data manually fill this structure in:             
                meta.tPerFile = 85;
                meta.filename='InitialSign_vsSustainedMIP_f%.4d_w%.4d.tif';   %Feb3LSCimgingMIP  Feb10imgingTP8to120MIP Feb10imgingTP1to7MIP
%                     meta.xres= 0.3250;
%                     meta.yres= 0.3250;
%                    meta.xSize= 1024;
%                    meta.ySize= 1024;
                meta.nZslices= 1;
               meta.nChannels= 2;
            meta.channelNames= {'Confocal 561'  'Confocal 488'};
    meta.excitationWavelength= [];
            meta.channelLabel= [];
                   meta.nTime= 85;
            meta.timeInterval= '15 min';
              meta.nPositions= 24;
          meta.montageOverlap= [];
         meta.montageGridSize= [];
                     meta.XYZ= zeros(16,1);
                     meta.raw= struct;
                  meta.nWells= [];
         meta.posPerCondition= [];
              meta.conditions= [];
meta.treatmentTime = 9;
meta.nWells = 4;
meta.posPerCondition = 4;
meta.conditions = {'A','A', 'B', 'B',...
              'B+'};
% SET THIS TO TRUE IF MAKING AN '8-well' LOOP THROUGH A 4-WELL
loop4well = true;
nucChannel = 2;
S4Channel = 1;
%tmax = meta.nTime;
tmax = meta.nTime;
 
% visualize positions
%---------------------
% meta.displayPositions;
% TODO: create merged cellData for montage
% movies of distribution over time           
%% save stitched previews of the MIPs

stitchedPreviews(dataDir, meta); 

%% extract nuclear and cytoplasmic levels
% externally I will have all indices starting at 1
% the Andor offset to start at 0 will be internal
%dataDir = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2017-02-03-BMP4wSB44hrs/LSConfocal20170201bmp4withSB5wells/';% saved the projections and ilastic output in a diff. dir
opts = struct(  'cytoplasmicLevels',    true,... %'tMax', 25,...
                    'dataChannels',     S4Channel,...
                    'fgChannel',        S4Channel,...%S4Channel
                    'segmentationDir',  fullfile(dataDir),...
                    'MIPidxDir',        [],...
                    'tMax',             tmax,...
                    'nucShrinkage',     1,...
                    'cytoSize',         6,...
                    'bgMargin',         10);

opts.cleanupOptions = struct('separateFused', true,...
    'clearBorder',true, 'minAreaStd',1, 'minSolidity',0, 'minArea',200);% 'minAreaStd', 1


%% check that the options are set right
%dataDir = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2017-02-03-BMP4wSB44hrs/LSConfocal20170201bmp4withSB5wells';% saved the projections and ilastic output in a diff. dir
ff = readAndorDirectory(dataDir);
pi =22;%11
% str = getAndorFileName(ff,ff.p(pi),[],0,0);
% meta.filename  = str(end-32:end);
P = DynamicPositionAndor(meta, pi);
time = 1;
opts.tMax = time;
% try out the nuclear cleanup settings on some frame:
% bla = nuclearCleanup(seg(:,:,time), opts.cleanupOptions);
% imshow(bla)

debugInfo = P.extractData(dataDir, nucChannel, opts);
%%
bgmask = debugInfo.bgmask;
nucmask = debugInfo.nucmask;
cytmask = false(size(nucmask));
cytmask(cat(1,debugInfo.cytCC.PixelIdxList{:}))=true;

bg = P.cellData(time).background;
nucl = P.cellData(time).nucLevelAvg;
cytl = P.cellData(time).cytLevelAvg;
(nucl-bg)/(cytl - bg)
(nucl)/(cytl);
im = P.loadImage(dataDir,S4Channel, time);%nucChannel S4Channel
MIP = max(im,[],3);
A = imadjust(mat2gray(MIP));
s = 0.6;
figure,imshow(cat(3, A + 0*bgmask, A + s*nucmask, A + s*cytmask));



%% run the analysis on all time points

tic
positions(meta.nPositions) = DynamicPositionAndor();

for pi = 16:(meta.nPositions)
    positions(pi) = DynamicPositionAndor(meta, pi);
    positions(pi).extractData(dataDir, nucChannel, opts);
    positions(pi).makeTimeTraces();
    save(fullfile('.','InitialSigng_vsSustained'), 'positions','-append');
end
toc
