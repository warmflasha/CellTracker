function setUserParamTrackSortingAN_20X
% add tracking parameters here ( pixel overlap threshold, max distance to
% move, etc
% 
global userParam;

 userParam.arealow = 100;
 userParam.minpxloverlap = 0.09;
 userParam.maxdist_tomove=25; 
 userParam.pxtomicron = 0.617284;% epi 20X:0.3125um/pxl; 0.617284 um/pxl on 20X, SDconfocal  ; 0.325000 um/pxl (40x)on SD confocal
 userParam.plottracks = 0;
 userParam.allowedgap = 2;
% userParam.backdiskrad = 200;%200
% userParam.colonygrouping = 90;% for the 40X

%userParam.areanuclow = 700;  % this is used only in the Unmerge nuclei function
%userParam.areanuchi = 9000;   % this is used only in the Unmerge nuclei function
userParam.areanuclow2 = 100; %800% this is used only in the Unmerge nuclei function

userParam.flag = 1;% two parameters below are determined dynamically
%userParam.areanuclow_unmerge = 3000 ;  % min area of the merged object to start the split ( very specific to the image, need to generalize(select this parameter based on each inpit image)
userParam.minnucfragment =150;       % smll, to be able to cut of junk like small dead bright cells
userParam.linedil = 5;                 % size of the strel to dilate the line cut
userParam.tocut = 400;% 230 if less then this parameter, don't cut


% userParam.probthresh_nuc = 0.7;% 0.7
% userParam.probthresh_cyto = 0.85;

% userParam.dilate_cyto = 5;
% userParam.erode_nuc = 8;% 10
% 
% userParam.areacytolow = 50;