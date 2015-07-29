function [outdat, nuc, fimg]=runOneMMDirec(direc,paramfile,nucchan)
tic;

global userParam;
try
    eval(paramfile);
catch
    disp('Error evaluating paramfile');
    return;
end

if ~exist('nucchan','var')
    nucchan = 'DAPI';
end

%get the filename structure
files=readMMsubdir(direc);

%read nuclear channel
filename = mkShortFileName(files,nucchan);
nuc=imread(filename);
nuc=smoothImage(nuc,userParam.gaussRadius,userParam.gaussSigma);

%other channels
if ischar(nucchan)
    nucnumber = find(~cellfun(@isempty,strfind(files.chan,nucchan)));
else
    nucnumber = nuc;
end
otherchannums = setdiff(1:length(files.chan),nucnumber);
nImages = length(otherchannums);

for ii=1:nImages
    filename=mkShortFileName(files,otherchannums(ii));
    fimg(:,:,ii)=imread(filename);    
end

nuc = smoothImage(nuc,userParam.gaussRadius,userParam.gaussSigma);

for xx=1:nImages
    fimg(:,:,xx) = smoothImage(fimg(:,:,xx),userParam.gaussRadius,userParam.gaussSigma);
end

if isfield(userParam,'presubNucBackground') && userParam.presubNucBackground
    nuc =presubBackground_self(nuc);
end

if isfield(userParam,'presubSmadBackground') && userParam.presubSmadBackground
    for xx=1:size(fimg,3)
        fimg(:,:,xx)=presubBackground_self(fimg(:,:,xx));
    end
end

[maskC, statsN]=segmentCells2(nuc,fimg);
[~, statsN]=addCellAvr2Stats(maskC,fimg,statsN);
outdat=outputData4AWTracker(statsN,nuc,nImages);

if userParam.verboseSegmentCells
    showImgAndPoints(nuc,outdat);
end
toc;


%%%
%AUX functions
%%%%
function files=readMMsubdir(subdir)

ff = dir([subdir filesep '*tif']);
files.direc = subdir;

if isempty(ff)
    ff=dir([subdir filesep 'Pos0' filesep '*.tif']);
    files.direc = [subdir filesep 'Pos0'];
end

if isempty(ff)
    disp('Error: didn''t find any .tif files');
    return;
end

for ii = 1:length(ff)
    dividers = find(ff(ii).name=='_');
    subprefix=ff(ii).name(1:(dividers(1)-1));
    time(ii) = str2double(ff(ii).name((dividers(1)+1):(dividers(2)-1)));
    chan{ii}=ff(ii).name((dividers(2)+1):(dividers(3)-1));
    z(ii)=str2double(ff(ii).name( (dividers(3)+1):(dividers(3)+3)));
end

files.subprefix = subprefix;
files.time=unique(time);
files.chan=unique(chan);
files.z=unique(z);

function filename=mkShortFileName(files,chan)

if ~exist('chan','var')
    chan = 1;
end

if ~ischar(chan)
    chan = files.chan{chan};
end

t=files.time;
t=int2str(t);
while length(t) < 9
    t = ['0' t];
end

z=files.z;
z=int2str(z);
while length(z) < 3
    z = ['0' z];
end

filename = [files.direc filesep files.subprefix '_' t '_' chan '_' z '.tif'];
