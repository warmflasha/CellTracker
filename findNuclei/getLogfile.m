function [logfile, path, folderday, chnum] = getLogfile(filename)
%
%   function [logfile, file_parse] = geLogfile(filename)
%
% Where filename is either a logfile, OR path that includes on it a folder
% with a logfile. EG '/Volumes/DATA/110210/ch51' will attempt to read the
% logfile '/Volumes/DATA/110210_experiment-log.txt'.
%   chnum is the number of the chamber or [] if inferring chnum from filename 
%
%   Returns 
%   file_parse = [path_toDATA, yymmdd, (int) chamber] (or [] if fails) and 
% NOT COMPLETE

fn_feedings = '_experiment-log.txt';  %% string that defines feeding file names

logfile = [];  path = []; folderday = [];  chnum = [];
if exist(filename, 'dir')  % looks only for dirs
    [path, folderday, chnum] = folder_num(filename);
    logname = [folderday, fn_feedings];
    logfile = [path, filesep, folderday, filesep, logname];
elseif exist(filename, 'file')  % looks for file OR dir
    [junk, name, ext, versn] = fileparts(filename);
    if strfind( [name ext], fn_feedings)
        logfile = filename;
        [path, folderday, chnum] = folder_num(filename);
    else
        fprintf(1, 'filename= %s did not match expected logfile name= %s\n', filename, fn_feedings);
    end
else
    fprintf(1,'getFeedings(): can not find file name %s\n', filename);
    return
end
return

function [path, folderday, chnum] = folder_num(name)
% take full path of form /../../110210/chddd/.. and extract all stuff upstream
% of yymmdd and return as path, return yymmdd as folderday, and parse stuff
% down stream for chddd, and return (int) chamber number

path = []; folderday = []; chnum= [];
while name
    [tok, name] = strtok(name, filesep);
    [num, status] = str2num(tok);
    if status
        folderday = tok;
        break;
    else
        path = [path filesep tok];
    end
end

if ispc
    path = path(2:length(path));
end

tok = strtok(name, filesep);
if strfind(tok, 'ch')
    [num, status] = str2num(tok(3:end));
    if status
        chnum = num;
    else
        chnum = [];
    end
end
