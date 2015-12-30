function runTracker(inmatfile, paramfile)
%
%% runTracker(inmatfile,paramfile)
%
% Function to match nuclei in successive frames and produce single cell
% trajectories.
%   inmatfile   is a .mat file produced by runSegmentCells and contains the
%               peaks{} array, (peaks{frame}(nuc#, x, y, .. fluor data)
%   paramfile   is an optional param file to reset userParam global, which
%               is otherwise taken from inmatfile
%
% On output:
%   inmatfile   is written out with added data, see last call.
%       In particular the peaks{} array gets a new 4th column which is the
%   number of the nuc on the next frame that the current nuc mapped to.
%
% cells struct array is created with fields (which get added by routine
% that computes them)
%
%   onframes    frame list
%   merge       0,1 if trajectories merged (see below)
%   good        0,1 if various filters passed
%   data        [onframes, 1:4] cols= [x,y,area,next-nuc-matched ie peaks{}(.,4)]
%   fdata       fluor data, nuc marker, [smad-nuc, smad-cyto] for 1 or 2
%               channels. organized as fdata(onframes, 1:3 or 1:5)
%   sdata       spline smoothed fdata, follows fdata organization
%   splines     [1:3 or 1:5] the spline coefs
%
% Misc notes:
%   The number of fluorescent columns of data is inferred from peaks{} via
% peaksTraj2AWCells() call. Inorder to read old files where peaks{} can
% have 9 columns for 2 color data (where last cols are cell-number and
% good), peaksTraj2AWCells() tries to detect these via the rule that 'true'
% fluor data is >=0 and has max over 10. THIS IS NOT GUARANTEED TO WORK.
% What the routine finds is printed, NB! For new data the peaks{} input to
% peaksTraj2AWCells() has either 7 or 9 cols corresp to 2,3 colors.
%   Note when rerunning old data, this routine overwrites cell() struct
% array in inmatfile, and cell2 array is not used here, but old copy will
% remain on inmatfile.
%
%   Various parameters passed to routines called here via global userParam
% call within each routine rather than arguments
%
%   doing splines data(frame#) rather than pictimes as in prev version, see
% orig AW findgoodcellsaddsplines(). pictimes in the .mat file.
%   Now computing splines using only fluor data >0, since fluor=0 occurs
% when no cyto found and thus should be skipped.
%   in GUI use only ratio of nuc/cyto splines to plot.
% singleCellPlot and averagePlot in analysis do the plots for GUI
%
%   Compute splines for all cells, since findBirthNodes() requires this.
% Uses about 25% more space on one data set with splines good cells only
%
% TODO organize where sizeImg is set
% define background mask and pass to matchFramesEDS and also findBirthNodes
% also define limits of chip area and use for boundaries in matchFrames

global userParam;

peaks=1; %cludgy fix b/c peaks is matlab function as well.
load(inmatfile);

try
    eval(paramfile);
catch
    fprintf(1, 'runTrackerEDS: could not evaluate parameter file supplied, using params from %s\n', inmatfile);
end


%use actual image size from segmentCells() if available
if ~exist('imgfiles','var')
    userParam.sizeImg = [1024 1024];
elseif isfield(imgfiles,'size')
    userParam.sizeImg=imgfiles(1).size;
    disp(['runTrackerEDS: Using img size from imgfiles: ' num2str(userParam.sizeImg) '.']);
elseif isfield(userParam, 'sizeImg')
    disp(['runTrackerEDS: Using userParam.sizeImg: ' num2str(userParam.sizeImg) '.']);
else
    userParam.sizeImg = [1024, 1024];
    disp(['runTrackerEDS: no image size in imgfiles() or userParam, using default image size= ' num2str(userParam.sizeImg) '.']);
end

if isempty(peaks{end})
    peaks=peaks(1:(end-1));
end

if any(cellfun(@isempty,peaks))
    disp('Frames missing; skipping.');
    return;
end


% match cells between successive frames, use adaptive parameters based on first few
% frames to define cost function
peaks=matchFramesEDS(peaks);

% merge trajectories if small gaps between nuclei linked in prev match.
traj = mainPeaks2Trajectories(peaks);

% convert data format, and add last col to peaks{} with cell number
[cells, peaks] = peaksTraj2CellObj(peaks, traj);

save(inmatfile,'cells','peaks','userParam','-append');

fprintf(1, '%s appended- cells, peaks to matfile= %s\n',mfilename,inmatfile);

return