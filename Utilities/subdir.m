function [ subfolderNames ] = subdir( directory )
%subdir outputs subfolders, a structure containing the dir
%   properties of only subdirectories within a directory
%   
directory = dir(directory);
dirFlags = [directory.isdir];
subfolders = directory(dirFlags); %list only sub-directories
subfolders(1:2) = []; %get rid of . and ..
for iSubfolders = 1:length(subfolders);
    subfolderNames{iSubfolders} = subfolders(iSubfolders).name;
end
end

