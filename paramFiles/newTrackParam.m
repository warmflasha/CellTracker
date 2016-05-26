function newTrackParam

global userParam;

userParam.L = 25;
userParam.sizeImg = [1024, 1024];

userParam.verboseCellTrackerEDS = 0;
userParam.minTrajLen = 5;%4
userParam.mergeGap = 2;%2 6
userParam.sclDstCost = [1 2];
userParam.minlength = 20;
userParam.mincyto = 0;
userParam.splineparam = 0.9;