function [mask2]=readIlastikProbMask(filename,thresh)

% if the probabilities map is supplied
if ~exist('foreground','var')
    foreground = 1;
end

immask = h5read(filename, '/exported_data');
immask2 = squeeze(immask(foreground,:,:,:));

mask = imcomplement(immask2) > thresh;

for ii = 1:size(mask,3)
    mask2(:,:,ii) = mask(:,:,ii)';    
end
%imshow(mask2(:,:,1),[])
end
