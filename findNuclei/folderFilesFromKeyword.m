function [range, list] = folderFilesFromKeyword(folder, key, useonly)
%
%   [range, list] = folderFilesFromKeyword(folder, key)
%
% given folder, find all file names that contain the keyword key. Decompose
% their names into [prefix, range_of_numbers, suffix]. 
%   The prefix and suffix are
% common to all names and the numbers are ints in format 0,1,2.. or
% 000,001,..100,.. and where some ints may be missing.
%
% list is struct array with fields
%   .name   = string with file name
%   .datenum = the numerical date as output by datenum
%
% The elements of int array range and list correspond and length <=
% max(range)+1. (ie +1 if names start with 000)
%
% If all names with 'key' are not in assumed format then return [] arrays with
% warning and offending name


    range=[]; 
    list = struct('name', [], 'datenum', []);

    
    if exist('useonly','var') && ~iscell(useonly)
        useonly = {useonly};
    end
    
    dirlist = dir(folder);
    if( ~ length(dirlist) )
        fprintf(1, 'folder= %s not found or empty\n', folder);
        return
    end

    ctr = 0;
    for ii = 1:length(dirlist)
        name = dirlist(ii).name;
        if( ~isempty(strfind(name, key)) ) && (~exist('useonly','var') || isempty(useonly) || strfindmulti(name,useonly) )
            ctr = ctr + 1;
            tmp(ctr).name = name;
            tmp(ctr).datenum = dirlist(ii).datenum;
            names{ctr} = name; 
        end
    end

    % if only one file with 'key' unclear how to parse names, range arbitrary
    if ctr < 1
        fprintf(1, 'found no file names with keyword= %s in folder= %s\n', key, folder);
        return
    end
    if ctr==1
        range = 1;
        list = tmp;
        fprintf(1, 'found 1 file= %s with keyword= %s in folder= %s, assume range=1\n',...
            list(1).name, key, folder);
    end
   
    % find prefix, suffix
    prefix = find_prefix(names);
    suffix = find_suffix(names);
    if isempty(prefix) || isempty(suffix)
        fprintf(1, 'no valid prefix or suffix found for files with keyword= %s in folder= %s returning []\n', key, folder);
        return
    end
    
    % check each name is of desired form, 
    next = length(prefix)+1;
    range = zeros(1, ctr);
    for i = 1:ctr
        digits = names{i}(next:end);
        k = strfind(digits, suffix);
        if ~isempty(k)
            digits = digits(1:(k-1));
        else
            fprintf(1, 'no valid digits found in name= %s. Using prefix= %s, suffix= %s\n',...
                names{i}, prefix, suffix);
            return
        end
        digits = str2num(digits);
        if ~isempty(digits) && isnumeric(digits)
            range(i) = digits;
        else
            fprintf(1, 'no valid digits found in name= %s. Using prefix= %s, suffix= %s\n',...
                names{i}, prefix, suffix);
            return
        end
    end
   
    % sort data into numerical order, (should also check times monotonic)
    [range, ix] = sort(range);
    list = tmp(ix);
    
    if ~ issorted( [list.datenum] )
        fprintf(1, 'WARNING the datenum on file names is not monotonic after sorting names\n' )
    end

    % success!! print message    
    fprintf(1, 'decomposed all fn in dir= %s with keyword= %s, into\n   prefix= %s, suffix= %s, and %d numbers from %d to %d\n',...
        folder, key, prefix, suffix, length(range), range(1), range(end) );
    return
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function prefix = find_prefix(names)
    %
        prefix = [];
        for i = 1:length(names{1})
            an = names{1}(i);
            for j = 2:length(names)
                if ~strcmp(an, names{j}(i))
                    if isempty(prefix)
                        fprintf(1, 'no consistent prefix found for names=..\n');
                        names{1:j}
                    end
                    return
                end
            end
            prefix = [prefix, an];
        end
            
    function suffix = find_suffix(names)
    %
        suffix = [];
        for i = 0:(length(names{1})-1)
            an = names{1}(end-i);
            for j = 2:length(names)
                if ~strcmp(an, names{j}(end-i))
                    if isempty(suffix)
                        fprintf(1, 'no consistent suffix found for names=..\n');
                        names{1:j}
                    end
                    return
                end
            end
            suffix = [an, suffix];
        end
        
        function found = strfindmulti(str,cellpatterns)
            npat = length(cellpatterns);
            nfound = 0;
            for ii = 1:npat
                if ~isempty(strfind(str,cellpatterns{ii}))
                    nfound = nfound + 1;
                end
            end
            
            if nfound == npat
                found = true;
            else
                found = false;
            end
            
                
            
 
    