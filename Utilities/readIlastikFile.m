function mask = readIlastikFile(filename,complement)
% mask = readIlastikFile(filename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read ilastik h5 file and output binary mask.
% complement will take the complement of the mask. use this if the objects
% are label 1. If bg is label 1, then set complement = 0.

if ~exist('complement','var')
    complement = 1;
end

immask = h5read(filename, '/exported_data');
immask = squeeze(immask);

mask = immask > 1;
if complement
    mask = imcomplement(mask);% if object 1 refers to background, comment this statement.
end

mask = permute(mask,[2 1 3]); % transpose the x and y dimensions