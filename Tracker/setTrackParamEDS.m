function setTrackParamEDS
global userParam;

userParam.sizeImg = [1024 1024];

%Parameters for tracking
userParam.L = 30; % this is the max distance (in pixels) objects in successive
                  %frames can be separated by and still match
% The time interval over which all traj-ends are pooled to test for cost of
% merger
userParam.mergeGap = 4;
                  
% Trajectories < this length (ie #times) are discarded
userParam.minTrajLen = 1;
userParam.minTrajLen = max(2, userParam.minTrajLen);

% dst cost to map cell to dummy is sclDstCost(1)*DT*mean +
% sclDstCost(2)*Sqrt(DT)*std, where DT = mergeGap (should be actual time diff), and mean, std
% are computed from continuous trajectories from AW code.
userParam.sclDstCost = [1,2];

%%%% TEMP PARAM size of image unless supply with mask of CCC defining
%%%% boundaries.
%userParam.sizeImg = size(img);
% userParam.sizeImg = [1024, 1344]; %[0,0];  %for eds test data)

% Verbose 1 or 2 or 3
userParam.verboseCellTrackerEDS = 1;
                  
%parameters for trajectory selection and spline fitting
userParam.minlength=25; %minlength of trajectories to be considered good
userParam.mincyto = 0.8; %minimum fraction of points with cytoplasm detected
userParam.splineparam=0.95; %spline parameter (from 0 to 1)
userParam.devthresh = 0.2; %maximum fraction deviation between trajectory
                            %and spline to be considered good
userParam.useframes=[]; %set if only want to use a subset of
                          %the frames for decision/spline fit. set to [] to
                          %use all frames