function runSegmentCellsZstack(direc,pos,chan,paramfile,outfile,nframes)
%
%   runSegmentCells(direc,outfile,nframes,nucstring,smadstring,paramfile)
%



global userParam;

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

%main loop over frames
for ii=1:min(nframes,length(ff.t))
    
    tic;
    disp(['frame ' int2str(ff.t(ii))]);
    % setup string to hold all the error messages for this frame number
    userParam.errorStr = sprintf('frame= %d\n', ii);
    
    if ~isempty(chan)
        nuc=andorMaxIntensity(ff,pos,ff.t(ii),chan(1));
    else
        nuc=andorMaxIntensity(ff,pos,ff.t(ii),[]);
    end
    
    if isempty(chan) || length(chan) == 1
        fimg = nuc;
    else
        for ii=2:length(chan)
            fimg(:,:,ii-1)=andorMaxIntensity(ff,pos,ff.t(ii),chan(ii));
        end
    end
    
    nuc = smoothImage(nuc,userParam.gaussRadius,userParam.gaussSigma);
    for ii=1:size(fimg,3)
        fimg(:,:,ii) = smoothImage(fimg(:,:,ii),userParam.gaussRadius,userParam.gaussSigma);
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
        rethrow(err);
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