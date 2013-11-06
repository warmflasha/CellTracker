function runTracker(inmatfile,paramfile)
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

global userParam;

peaks=1; %cludgy fix b/c peaks is matlab function as well.
load(inmatfile);

try
    eval(paramfile);
catch
    error('Could not evaluate parameter file.');
end

verbose=userParam.verboseCellTrackerEDS;

%use actual image size if available
if exist('imgfiles','var') && isfield(imgfiles,'size')
    userParam.sizeImg=imgfiles(1).size;
    if verbose
        disp(['runTracker: Using actual image size: ' num2str(userParam.sizeImg) '.']);
    end
else
    if verbose
        disp(['runTracker: Using default image size: ' num2str(userParam.sizeImg) '.']);
    end
end

for ii=2:length(peaks)
    peaks=MatchFrames(peaks,ii);
end

traj = mainPeaks2Trajectories(peaks);
[cells, peaks] = peaksTraj2AWCells(peaks, traj);
cells = addSplines2Cells(cells);

% adds 0|1 field to cells
cells = findGoodCells(cells);
cells = addLocalMax2Cells(cells);

save(inmatfile,'cells','peaks','-append');
