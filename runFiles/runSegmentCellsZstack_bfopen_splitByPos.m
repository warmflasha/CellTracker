function runSegmentCellsZstack_bfopen_splitByPos(direc,pos,chan,paramfile,outfile)
%
%   runSegmentCells(direc,outfile,nframes,nucstring,smadstring,paramfile)
%__________________________
% Assumes files are split by position and possible time but with several
% timepoints in each file.





global userParam;

usebfopen = 1;

try
    eval(paramfile);
catch
    error('Could not evaluate paramfile command');
end

ff=readAndorDirectory(direc);

if length(chan) < 2
    nImages = 1;
else
    nImages=length(chan)-1;
end

if isempty(ff.t)
    ntimefiles = 1;
else
    ntimefiles = length(ff.t);
end

nimg = 1;
%main loop over frames
for ii=1:ntimefiles
    
    tic;
    
    filename = getAndorFileName(ff,pos,ii-1,[],[]);
    reader = bfGetReader(filename);
    
    nT = reader.getSizeT;
    
    for jj = 1:nT
        
        nuc = bfMaxIntensity(reader,jj,chan(1));
        for xx=2:length(chan)
            fimg(:,:,xx-1) = bfMaxIntensity(reader,jj,chan(2));
        end
        
        disp(['frame ' int2str(nimg)]);
        % setup string to hold all the error messages for this frame number
        userParam.errorStr = sprintf('frame= %d\n', ii);
        
        
        
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
        imgfiles(nimg).filestruct=ff;
        imgfiles(nimg).pos = pos;
        imgfiles(nimg).w = chan;
        
        %run routines to segment cells, do stats, and get the output matrix
        try
            [maskC, statsN]=segmentCells2(nuc,fimg);
            [~, statsN]=addCellAvr2Stats(maskC,fimg,statsN);
            outdat=outputData4AWTracker(statsN,nuc,nImages);
        catch err
            disp(['Error with image ' int2str(ii) ' continuing...']);
            
            peaks{nimg}=[];
            statsArray{nimg}=[];
            rethrow(err);
            continue;
        end
        
        % copy over error string, NOTE different naming conventions in structs userParam
        % vs imgfiles.
        imgfiles(nimg).errorstr = userParam.errorStr;
        if userParam.verboseSegmentCells
            display(userParam.errorStr);
        end
        % compress and save the binary mask for nuclei
        imgfiles(nimg).compressNucMask = compressBinaryImg([statsN.PixelIdxList], size(nuc) );
        peaks{nimg}=outdat;
        
        %This prevents the resulting mat files from becoming too large.
        statsN = rmfield(statsN,'VPixelIdxList');
        statsArray{ii}=statsN;
        nimg = nimg + 1;
        toc;
    end
end

dateSegmentCells = clock;
save(outfile,'peaks','statsArray','imgfiles','userParam','dateSegmentCells');

