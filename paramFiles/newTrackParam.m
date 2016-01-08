function newTrackParam

global userParam;

% <<<<<<< HEAD
% userParam.L = 80;
% userParam.sizeImg = [2048, 2048];
% =======
userParam.L = 70;
userParam.sizeImg = [1024, 1024];

userParam.verboseCellTrackerEDS = 0;
userParam.minTrajLen = 10;%4
userParam.mergeGap = 10;%2
userParam.sclDstCost = [1 2];
userParam.minlength = 20;
userParam.mincyto = 0;
userParam.splineparam = 0.9;