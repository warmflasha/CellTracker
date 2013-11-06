function runTrackerEDS(inmatfile, paramfile)
%% runTrackerCCCwithEDStraj(inmatfile,paramfile)
%function runTrackerCCC(inmatfile,paramfile)
%-------------------------------------------
%function to match objects in successive frames and
%produce single cell trajectories. inmatfile is a matfile
%outputed by runSegmentCells and contains the peaks array.
%will overwrite peaks in inmatfile with 4th data column filled in
%(this is the match column) as well as appending cells structure
% containing the single cell trajectories to inmatfile.
% paramfile is an optional paramfile command which will be run
%at the begining and sets the tracking parameters. If an integer
%is supplied then it will set userParam.L=paramfile. If no argument
%supplied it will use the parameters stored in inmatfile.
%
% TODO organize where sizeImg is set
% define background mask and pass to matchFramesEDS and also findBirthNodes

global userParam;

peaks=1; %cludgy fix b/c peaks is matlab function as well.
load(inmatfile);

try
    eval(paramfile);
catch
    fprintf(1, 'runTrackerEDS: could not evaluate parameter file supplied, using params from %s\n', inmatfile);
end

% following 3 calls may be subsumed into userParam file, but in running old
% data these calls may be needed
userParam.verboseCellTrackerEDS = 1;
userParam.useCCC = 1;  % assume CCC data
setTrackParamEDS();

%use actual image size if available
if isfield(imgfiles,'size')
    userParam.sizeImg=imgfiles(1).size;
    if userParam.verboseCellTrackerEDS
        disp(['runTrackerEDS: Using actual image size: ' num2str(userParam.sizeImg) '.']);
    end
elseif isfield(userParam, 'sizeImg')
    if userParam.verboseCellTrackerEDS
        disp(['runTrackerEDS: Using userParam.sizeImg: ' num2str(userParam.sizeImg) '.']);
    end
else
    userParam.sizeImg = [1024, 1344];
    disp(['runTrackerEDS: no image size in imgfiles() or userParam using default image size= ' num2str(userParam.sizeImg) '.']);
end

% match cells between successive frames, use adaptive parameters based on first few
% frames to define cost function
peaks=matchFramesEDS(peaks);

% merge trajectories if small gaps between nuclei linked in prev match.
traj = mainPeaks2Trajectories(peaks);

% convert data format, and update peaks{}
[cells, peaks] = peaksTraj2AWCells(peaks, traj);

% see this routine for defn of births struct array
births = findBirthNodes( cells, peaks );

cells2=decideifgoodaddspline(cells,pictimes,userParam.minlength,...
    userParam.mincyto,userParam.splineparam,userParam.devthresh,...
    userParam.useframes);

cells2 = addLocalMax2Cells(cells2);

peaks=addgoodtopeaks(cells2,peaks);

save(inmatfile,'cells','cells2','peaks','births','-append');
return
