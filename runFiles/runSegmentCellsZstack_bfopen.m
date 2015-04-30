function runSegmentCellsZstack_bfopen(direc,pos,chan,paramfile,outfile,nframes)
%
%   runSegmentCells(direc,outfile,nframes,nucstring,smadstring,paramfile)
%



global userParam;

usebfopen = 1;

try
    eval(paramfile);
catch
    error('Could not evaluate paramfile command');
end

ff=readAndorDirectory(direc);
if ~exist('nframes','var')
    nframes = length(ff.t);
end

if length(chan) < 2
    nImages = 1;
else
    nImages=length(chan)-1;
end    

for ww=1:length(ff.w)
    for zz=1:length(ff.z)
        filename = getAndorFileName(ff,pos,0,ff.z(zz),ff.w(ww));
        tmpimg = bfopen(filename);
        imgs{ww,zz}=tmpimg{1};
    end
end

ntimes = size(imgs{1,1},1);


%main loop over frames
for ii=1:min(ntimes,nframes)
    
    tic;
    disp(['frame ' int2str(ii)]);
    % setup string to hold all the error messages for this frame number
    userParam.errorStr = sprintf('frame= %d\n', ii);
    
    nuc=imgs{1,1}{ii,1};
    fimg(:,:,1)=imgs{2,1}{ii,1};
    for zz=2:length(ff.z)
        nuc=max(nuc,imgs{1,zz}{ii,1});
        fimg(:,:,1)=max(fimg(:,:,1),imgs{2,zz}{ii,1});
    end
    
    
    nuc = smoothImage(nuc,userParam.gaussRadius,userParam.gaussSigma);
    for xx=1:size(fimg,3)
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
    
    %record some info about image file.
    imgfiles(ii).filestruct=ff;
    imgfiles(ii).pos = pos;
    imgfiles(ii).w = chan;
    
    %run routines to segment cells, do stats, and get the output matrix
    try 
        [maskC, statsN]=segmentCells2(nuc,fimg);
        [~, statsN]=addCellAvr2Stats(maskC,fimg,statsN);
        outdat=outputData4AWTracker(statsN,nuc,nImages);
    catch err
        disp(['Error with image ' int2str(ii) ' continuing...']);
        
        peaks{ii}=[];
        statsArray{ii}=[];
        %rethrow(err);
        continue;
    end

    % copy over error string, NOTE different naming conventions in structs userParam
    % vs imgfiles.
    imgfiles(ii).errorstr = userParam.errorStr;
    if userParam.verboseSegmentCells
        display(userParam.errorStr);
    end
    % compress and save the binary mask for nuclei
    imgfiles(ii).compressNucMask = compressBinaryImg([statsN.PixelIdxList], size(nuc) );
    peaks{ii}=outdat;
    
    %This prevents the resulting mat files from becoming too large.
    statsN = rmfield(statsN,'VPixelIdxList');
    statsArray{ii}=statsN;
    
    toc;
end

dateSegmentCells = clock;
save(outfile,'peaks','statsArray','imgfiles','userParam','dateSegmentCells');