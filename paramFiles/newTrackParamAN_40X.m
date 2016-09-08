function newTrackParamAN_40X

global userParam;


userParam.L = 80;% 120 for 60X  % 70 for 40X
userParam.sizeImg = [1024, 1024];

userParam.verboseCellTrackerEDS = 0;
userParam.minTrajLen = 4;%4
userParam.mergeGap = 4;%3 
userParam.sclDstCost = [1 2];
userParam.minlength = 20;
userParam.mincyto = 0;
userParam.splineparam = 0.9;