function setTrackParam
global userParam;

%Parameters for tracking

% this is the max distance (in pixels) objects in successive frames can be separated 
% by and still match. If <0 then compute adaptively from data
userParam.L = -1; 

% The time interval over which all traj-ends are pooled to test for cost of
% merger
userParam.mergeGap = 4;
                  
% Trajectories < this length (ie #times) are discarded
userParam.minTrajLen = 4;
userParam.minTrajLen = max(2, userParam.minTrajLen);

% dst cost to map cell to dummy is sclDstCost(1)*DT*mean +
% sclDstCost(2)*Sqrt(DT)*std, where DT = mergeGap (should be actual time diff), and mean, std
% are computed from continuous trajectories from AW code.
userParam.sclDstCost = [1,2];

% Should set sizeImg when doing segmentation, and it should be set in userParam
% that exists before this rountine called.
% userParam.sizeImg = [512, 512]; %[0,0];  %for eds test data)

% Verbose 1 or 2 or 3
userParam.verboseCellTrackerEDS = 1;
                  
%parameters for trajectory selection and spline fitting
userParam.minlength=10; %minlength of trajectories to be considered good
userParam.mincyto = 0; %minimum fraction of points with cytoplasm detected
userParam.splineparam=0.995; %spline parameter (from 0 to 1)
userParam.devthresh = 1; %maximum fractional deviation between trajectory
                            %and spline to be considered good
userParam.useframes=[]; %set if only want to use a subset of
                          %the frames for decision/spline fit. set to [] to
                          %use all frames
                          
% auxillary parameters to control other function
userParam.nobirths = 1;