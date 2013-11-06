function rerunStats4SegmentCells(dirname, keyword, nframes, paramfile, backgroundstr)
%
%   rerunStats4SegmentCells(dirname, keyword, nframes, paramfile, backgroundstr)
%
%   Take a matfile produced by runSegmentCells located in a directory=dirname
% with a basename containing the keyword=keyword, and rerun the average
% statistics for the smad image files. This only works with forceDonut=1 since
% the cell mask from segmentCells() is not saved. All the file names taken from
% matfile.imgfiles(). Other input variables..
%
%   nframes     = run frames from imgfile(i) for i=1:min(nframes, frames in file)
%   paramfile   = name of setUserParam file to eval to get new params
%   backgroundstr = same as in runSegmentCells NOT CHECKED. Omit arg to skip.
%
% Output is a new matfile with basename = new_'oldmatfile' written to CWD
% Most of the time is spent in recomputing the voronoi polygons,which are also
% not saved in matfile.

global userParam;

try
    eval(paramfile);
catch
    error('Could not evaluate paramfile command in rerunStats4SegmentCells() quitting');
end

if ~userParam.forceDonut
    error('Must use forceDonut=1 in rerunStats4SegmentCells() since maskCell = []');
end

matfile = dir( fullfile(dirname, ['*',keyword,'*mat']) );
if length(matfile) > 1 
    matfile.name;
    error('found more than one mat file in dir= %s with keyword= %s\n', dir, keyword);
end
if isempty(matfile)
    error('No file found in %s with keyword = %s\n', dirname, keyword);
end
% length(matfile) == 1
matfile = fullfile(dirname, matfile.name);
mat = load(matfile);
imgfiles = mat.imgfiles;
fprintf(1, 'loaded matfile= %s, #imgfiles= %d, imgfile(1)=\n',...
    matfile, length(imgfiles));
imgfiles(1)

%if reading in background images, get these file names
if exist('backgroundstr','var')
    disp('Using input image for background. Overriding settings in param file');
    userParam.backgndMethod=-1;
    if ischar(backgroundstr{1})
        diffbgimages=1;
        [nucbkgndrange nucbkgndfiles]=folderFilesFromKeyword(dirname,backgroundstr{1});
        [Smadbkgndrange Smadbkgndfiles]=folderFilesFromKeyword(dirname,backgroundstr{2});
    else
        diffbgimages=0;
    end
end
  
nImages = length(imgfiles(1).smadfile);
%main loop over frames
for ii=1:min(nframes, length(imgfiles))
    tic;
    %read the image files
    nuc = imread(fullfile(dirname, imgfiles(ii).nucfile));
    for jj=1:nImages
        fimg(:,:,jj) = imread( fullfile(dirname, imgfiles(ii).smadfile{jj}) );
    end
    if length(size(nuc))==3
        nuc=squeeze(nuc(:,:,1));
    end
    fprintf(1, 'working on frame= %d, read nuc file= %s\n', ii, imgfiles(ii).nucfile);
    
    %if using separate background files,read background files and subtract
    if userParam.backgndMethod==-1 && exist('backgroundstr','var')
        if diffbgimages == 1
            nbgi=find(nucbkgndrange==goodframes(ii));
            nucbkgndfilename=[dirname filesep nucbkgndfiles(nbgi).name];
            sbgi=find(Smadbkgndrange==goodframes(ii));
            Smadbkgndfilename=[dirname filesep Smadbkgndfiles(sbgi).name];
            nucbg=imread(nucbkgndfilename);
            smadbg=imread(Smadbkgndfilename);
        else
            nucbg=backgroundstr{1};
            smadbg=backgroundstr{2};
        end
        [nuc fimg]=presubBackground(nuc,fimg,nucbg,smadbg);
    end
    
    %if set, use imopen to generate background image and subtract from
    %nuc image
    
    if isfield(userParam,'presubNucBackground') && userParam.presubNucBackground
        nuc =presubBackground_self(nuc);
    end
    
    maskC = false([size(nuc), nImages]);
    [junk, statsN]=addCellAvr2Stats(maskC, fimg, mat.statsArray{ii} );
    outdat=outputData4AWTracker(statsN, nuc, nImages);
 
    mat.peaks{ii}=outdat;
    
    mat.statsArray{ii}=statsN;
    toc
end
% store new paramfile
mat.userParam = userParam;

% save updated mat file under new name in CWD
[junk, matfile, junk] = fileparts(matfile);
new_mat = ['new_', matfile];
save(new_mat, '-struct', 'mat');
fprintf(1, 'output new matfile= %s in CWD with updated peaks{}, statsArray{}\n', new_mat);

return