function setUserParam3DsegmentationAN_40X

global userParam;

% parameters for the 3d segmentation ( sapna/idse code)
% changed for the 40X data

userParam.logfilter = 12;% not used
userParam.bthreshfilter = 0.2;% 0.25 % not used
userParam.diskfilter = 3;%3  4
userParam.area1filter = 900;

userParam.minstartobj = 1;
userParam.minsolidity = [0.9, 0.5];%[0.9 0.7]
userParam.area2filter = 800;%1000

%userParam.zmatch = 4;% thisparameter is set in the function to be the size
%of the zrange (so that the foud nuclei would be traced throughout all
%nonempty zplanes)
userParam.matchdistance = 22;%15 10 

userParam.overlapthresh = 80;