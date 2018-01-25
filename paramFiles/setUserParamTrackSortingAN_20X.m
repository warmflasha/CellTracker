function setUserParamTrackSortingAN_20X
% add tracking parameters here ( pixel overlap threshold, max distance to
% move, etc
% 
global userParam;

 userParam.arealow = 50;%100
 userParam.minpxloverlap = 0.15;%0.09
 userParam.maxdist_tomove=17; % 25 in pixels
 userParam.pxtomicron = 0.617284;% epi 20X:0.3125um/pxl; 0.617284 um/pxl on 20X, SDconfocal  ; 0.325000 um/pxl (40x)on SD confocal
 userParam.plottracks = 0;
 userParam.allowedgap = 2;
 userParam.local_sz =47;% 47 in pixels     % size of the cell neighborhood to be considered
 userParam.probthresh =0.9;% if the ilasik probability maps are supplied
 
% userParam.colonygrouping = 90;% for the 40X

userParam.areanuclow2 = 100; %800% this is used only in the Unmerge nuclei function

userParam.flag = 1;% two parameters below are determined dynamically
userParam.minnucfragment =150;       % smll, to be able to cut of junk like small dead bright cells
userParam.linedil = 5;                 % size of the strel to dilate the line cut
userParam.tocut = 400;% 230 if less then this parameter, don't cut


