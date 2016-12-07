function runSegmentCellsMultipleMontagesJKM(direc,chan,paramfile,outfilePrefix)
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
%   
%   - outfilePrefix - prefix for outputfiles (I usually use 'out')

% Output data is saved in the output file inside of a new outfiles directory in peaks variable


mkdir('outfiles');


global userParam;

try
    eval(paramfile);
catch
    error('Could not evaluate paramfile command');
end

%main loop over imgfiles
imgFiles = dir([direc filesep '*.tif']);
    
for iImgFiles = 1: length(imgFiles);
disp(['Segmenting image ' int2str(iImgFiles) ' of ' int2str(length(imgFiles))]);
    filename = imgFiles(iImgFiles).name;
    
    
    h5file = geth5name(filename);
    
    
        usemask = 1;
        masks = readIlastikFile([direc filesep h5file]);
        if isfield(userParam,'maskDiskSize')
        masks = imopen(masks,strel('disk',userParam.maskDiskSize));
        end
    
    
        
         
        img = bfopen([direc filesep filename]);
        nuc = img{1}{chan(1)};
        
        if length(chan) == 1
            fimg = nuc;
        else
            
            for xx=2:length(chan)
                fimg(:,:,xx-1) = img{1}{chan(xx)};
            end
        end
        
        
        
        
       
        
        
        
        %run routines to segment cells, do stats, and get the output matrix
        
                
                [outdat, ~, statsN] = image2peaks(nuc, fimg, masks);
            
        catch err
            disp(['Error with image ' int2str(ii) ' continuing...']);
            
            peaks{iImgFiles}=[];
            statsArray{iImgFiles}=[];
            
            
            %rethrow(err);
            continue;
        
        
    [~,name,~] = fileparts(filename)
         
  dateSegmentCells = clock;
save(['outfiles' filesep outfilePrefix '_' name '.mat'],'peaks','statsArray','userParam','dateSegmentCells');
disp(['outfiles' filesep outfilePrefix '_' name '.mat has been saved']);
end
  disp(['All images and outfiles saved']);
end


