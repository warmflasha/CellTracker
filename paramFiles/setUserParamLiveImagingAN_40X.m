function setUserParamLiveImagingAN_40X
% these are good for the 60X imaging
% cell nuc area for the 40X imaging is ~ 1000-2000
global userParam;

userParam.gaussRadius = 5;%5
userParam.gaussSigma = 2;%2
userParam.small_rad = 20;%2
userParam.presubNucBackground = 1;
userParam.backdiskrad = 200;%200
userParam.colonygrouping = 90;% for the 40X

userParam.areanuclow = 700;  % this is used only in the Unmerge nuclei function
userParam.areanuchi = 9000;   % this is used only in the Unmerge nuclei function
userParam.areanuclow2 = 700; %800% this is used only in the Unmerge nuclei function

userParam.flag = 1;% two parameters below are determined dynamically
%userParam.areanuclow_unmerge = 3000 ;  % min area of the merged object to start the split ( very specific to the image, need to generalize(select this parameter based on each inpit image)
userParam.minnucfragment =400;       % smll, to be able to cut of junk like small dead bright cells
userParam.linedil = 6;                 % size of the strel to dilate the line cut
userParam.tocut = 100;% 230 if less then this parameter, don't cut


userParam.probthresh_nuc = 0.82;% 0.7
userParam.probthresh_cyto = 0.9;

userParam.dilate_cyto = 5;
userParam.erode_nuc = 8;% 10

userParam.areacytolow = 50;