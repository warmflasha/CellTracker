function mask = readIlastikFile(filename,complement)
% mask = readIlastikFile(filename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read ilastik h5 file and output binary mask.
% complement will take the complement of the mask. use this if the objects
% are label 1. If bg is label 1, then set complement = 0.

if ~exist('complement','var')
    complement = 0;
end

immask = h5read(filename, '/exported_data');
immask = squeeze(immask);

mask = immask > 1;
if complement
    mask = imcomplement(mask);
end


for ii = 1:size(mask,3)
    mask2(:,:,ii) = mask(:,:,ii)';
end

mask = mask2;