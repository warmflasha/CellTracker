function [range, list] = folderFilesFromKeyword(folder, key)
%
%   [range, datenum] = folderFilesFromKeyword(folder, key)
%
% given folder, find all file names that contain the keyword key. Decompose
% their names into [prefix, range_of_numbers, suffix]. The range of numbers
% is given as numerical list, but the numbers have to be left padded with
% 0's to build the file names.  ASSUMES ALL FILE NAMES WITH KEY HAVE SAME
% LENGTH, and differ only in digits. 
%
%   list is struct array with max(range)+1 elements, indexed by number of file
% which may start with 0.  List has fields
%       .name   = string with file name
%       .datenum = the numerical date as output by datenum

    prefix=[]; suffix=[]; range=[]; 
    list = struct('name', [], 'datenum', []);
    
    dirlist = dir(folder);
    if( ~ length(dirlist) )
        fprintf(1, 'folder= %s not found or empty\n', folder);
        return
    end
    
    names = [];
    for ii = 1:length(dirlist)
        name = dirlist(ii).name;
        if( strfind(name, key) )
            if( length(names) && length(name) ~= size(names, 2) )
                fprintf(1, 'fn= %s in folder= %s does not match previous %s, skipping\n',...
                    name, folder, names(end, :) );
                continue
            end
            names = [names; name];  % code will die here if not all names same length
        end
    end
    
    if( ~length(names) )
        fprintf(1, 'found no file names with keyword= %s in folder= %s\n', key, folder);
        return
    end
    
    len = length(names(1,:));
    for ii = 1:len
        col = unique(names(:,ii) );
        if( length(col) == 1 )
            prefix = [prefix, col];
        else
            break
        end
    end
    
    for ii = len:-1:1
        col = unique(names(:,ii) );
        if( length(col) == 1 )
            suffix = [col, suffix];
        else
            break
        end
    end
    
    char1 = length(prefix) + 1;
    char2 = length(names(1,:)) - length(suffix);
    [range, status] = str2num(names(:, char1:char2 ) );
    if ~status
        fprintf(1, 'folderFilesFromKeyword(): ERROR prefix= %s suffix= %s\n', prefix, suffix);
        fprintf(1, '  str2num failed, names not in form [prefix digits suffix], numerical range found..\n');
        range
        names
        return
    end
    range = sort(range);
    max_range = range(end);
    fprintf(1, 'decomposed all fn in dir= %s with keyword= %s, into\n prefix= %s suffix= %s and %d numbers from %d to %d\n',...
        folder, key, prefix, suffix, length(range), range(1), max_range );
    
    list(1) = struct('name', [], 'datenum', []);
    for ii = 1:length(dirlist)
        name = dirlist(ii).name;
        if( strfind(name, key) )
            [filenum, status] = str2num(name(char1:char2) );
            if ~status
                fprintf(1, 'folderFilesFromKeyword(): str2num failed in final list name= %d, char1,2= %d %d\n',...
                    name, char1, char2);
            end
            list(filenum).name = name;
            list(filenum).datenum = dirlist(ii).datenum;
        end
    end
    
    
    