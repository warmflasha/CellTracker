function processFolderRedGr(folder, last_time, setUserParam)
%
%   processFolder(folder (char), last_time (int), setUserParam (char) )
% 
% Read all files whose name contains keywords red or green in the folder.
% optional arguments: (omit, or supply int, or supply int, char )
%   last_time is the last integer 'time' to be processed or huge int to ignore
%   setUserParam is a char so that eval(setUserParam) sets desired 
%   global userParam
%
% Assume the file names are of the form [prefix number suffix], where number is time
% (int)
%   red is the nuclear marker, 
%   green is cyto marker, that is averaged over cytoplasm and nucleus
% Extract the numbers, order and then apply any desired function to each
% file. Note folder may skip some ints in the file numbering, last_time refers to
% number in file name.
%   Options to read a feeding schedule and print feeding history for each image
% and to save files for multiple times for latter tracking
%
%   Need edit main loop to process selected files eg in verbose mode to verify
% that segmentation working via images. 
%
    clear global userParam
    global userParam;
    
    if nargin == 3 && isa(setUserParam, 'char')
        eval(setUserParam);
    else
        setUserParamCCC10x([]);
    end
    userParam.batch = 1;  % needed so that setUserParam not recalled in segmentCells
    
    [logfile, path, yymmdd, chnum] = getLogfile(folder);
    if exist(logfile, 'file')
        feedings = getFeedings(logfile, chnum, 0);
    else
        fprintf(1, 'can not find feeding logfile on path to folder= %s\n', folder);
        feedings = [];
    end
    
    % name of file.mat in CWD to which various outputs saved. Overwrites file if
    % exists. mat file format defined by AW for tracker etc. Use savefile=[] to
    % skip.
    savefile = ['stats', yymmdd, 'ch', num2str(chnum), '.mat'];
    savefile = [];
    
    % range is a list of ints, listR(range) is struct all the valid file names and
    % dates. 
    
    [rangeR, listR] = folderFilesFromKeyword(folder, 'red');
    [rangeG, listG] = folderFilesFromKeyword(folder, 'green');
    %[rangeR, listR] = folderFilesFromKeyword(folder, 'GFP_s1');
    %[rangeG, listG] = folderFilesFromKeyword(folder, 'Rhodamine_s1');
    %[rangeR, listR] = folderFilesFromKeyword(folder, 'Rhodamine_s1');
    %[rangeG, listG] = folderFilesFromKeyword(folder, 'GFP_s1');
    %[rangeR, listR] = folderFilesFromKeyword(folder, 'w3YFP');
    %[rangeG, listG] = folderFilesFromKeyword(folder, 'w3YFP');
    
    if (length(rangeR) ~= length(rangeG)) || any(rangeR - rangeG)
        fprintf(1, 'WARNING int valued vectors with file times are not consistent, quitting\n');
        rangeR
        rangeG
        return
    end
    
    % can reset the range and spacing of file numbers after this line.  
    % Note data files can skip time points and range* may not be consecutive
    % ints
    
    for ii = 1:1:99 %%
    %for ii = 1:length(rangeR)
        last_ii = find( rangeR > last_time, 1, 'first');
        if nargin >= 2 && ~isempty(last_ii) && ii > last_ii
            continue
        end
   
        nameG = listG(ii).name;   
        nameG = [folder, filesep, nameG];
        imgG = imread(nameG);
        dateG = datestr( listG(ii).datenum);
        
        nameR = listR(ii).name;  
        nameR = [folder, filesep, nameR];
        imgR = imread(nameR);
        dateR = datestr( listR(ii).datenum);
        
        if(mod(ii,1) == 0)
            fprintf(1, '\nprocessFolder(): diagnostic plots for file number= %d, %s', rangeR(ii), listR(ii).name);
            userParam.verboseCountNuc = 2;
            userParam.verboseFindNucThresh = 1;
            userParam.verboseSegmentCells = 1;
        else
            fprintf(1, '\nprocessFolder(); working on file number= %d', rangeR(ii) );
            userParam.verboseCountNuc = 0;
            userParam.verboseFindNucThresh = 0;
            userParam.verboseSegmentCells = 0;
        end
        fprintf(1, '\ntime red,gr images= %s %s, feeding history..\n', dateR, dateG);
        feedingHistory(feedings, listG(ii).datenum );
        [maskCells, statsN] = segmentCells(imgR, imgG);          
        [maskNonNuc, statsN] = addCellAvr2Stats(maskCells, imgG, statsN);
        
        % output data array for AW tracker function, 
        outdata = outputData4AWTracker(statsN, imgR); 

        % diagnostic plots, can run interactively if stop loop in editor
        plotHistStats( statsN, ii);
        
        % optionally save all the data. Eliminate the voronoi field to make statsN smaller 
        % otherwise numel(statsN) ~ img, also eliminate nucs
        if ~isempty(savefile)
            statsN = rmfield(statsN, {'VPixelIdxList', 'PixelIdxList'});
            statsArray{ii} = statsN;  % might save maskC as separate field etc
            peaks{ii} = outdata;
            
            pictimes(ii)=(listR(ii).datenum  - listR(1).datenum)*24;
            imgfiles(ii).nucfile = nameR;  
            imgfiles(ii).smadfile = nameG;
            imgfiles(ii).time = pictimes(ii);
        end
    end

    if ~isempty(savefile)
        pictimes = reshape(pictimes, [], 1);
        dateSegmentCells = clock;
        if exist('logfile') && exist('chnum')  
            feedings=getFeedings(logfile, chnum, listR(rangeR(1)).datenum);
            save(savefile,'peaks','statsArray','imgfiles','userParam','pictimes','dateSegmentCells','feedings');
        else
            save(savefile,'peaks','statsArray','imgfiles','userParam','pictimes','dateSegmentCells');
        end
        fprintf(1, 'wrote savefile= %s, statsArray has %d elements\n', savefile, length(statsArray));
    end
    
    