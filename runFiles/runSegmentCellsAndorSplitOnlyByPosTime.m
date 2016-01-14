function runSegmentCellsAndorSplitOnlyByPosTime(direc,pos,chan,paramfile,outfile)
% runSegmentCellsZstack_bfopen_splitByPos(direc,pos,chan,paramfile,outfile)
%__________________________
% Assumes files are split only by position and possible time but with several
% timepoints in each file. All z-positions and channels must be in one
% file.
% Inputs:
%   -direc - directory containing images
%   - pos - position number
%   - chan - list of channels (1st for segmentation, others to quantify)
%       NOTE: starts from 1 for consistency with other routines
%   - paramfile - paramter file to use
%   - outfile - output .mat file
%   - nframes (optional) number of frames to run. If not supplied will run
%   all
% Output data is saved in the output file in peaks variable with image information
% in imgfiles variable.





global userParam;

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
    
    h5file = geth5name(filename);
    
    if exist(h5file,'file')
        usemask = 1;
        masks = readIlastikFile(h5file);
    else
        usemask = 0;
    end
    
    for jj = 1:nT
        
        nuc = bfMaxIntensity(reader,jj,chan(1));
        
        if length(chan) == 1
            fimg = nuc;
        else
        
        for xx=2:length(chan)
            fimg(:,:,xx-1) = bfMaxIntensity(reader,jj,chan(2));
        end
        end
        
        disp(['frame ' int2str(nimg)]);
        % setup string to hold all the error messages for this frame number
        userParam.errorStr = sprintf('frame= %d\n', nimg);
        
        [nuc, fimg] = preprocessImages(nuc,fimg);
        
        %record some info about image file.
        imgfiles(nimg).filestruct=ff;
        imgfiles(nimg).pos = pos;
        imgfiles(nimg).w = chan;
        
        
        
        
        %run routines to segment cells, do stats, and get the output matrix
        try
            if usemask
                disp(['Using ilastik mask frame ' int2str(jj)]);
                [outdat, ~, statsN] = image2peaks(nuc, fimg, masks(:,:,jj));
            else
                disp(['Segmenting frame ' int2str(jj)]);
                [outdat, ~, statsN] = image2peaks(nuc,fimg);
            end
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

