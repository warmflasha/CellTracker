
function [newmask] = lblmask_3Dnuc(CC,nucleilist)
% function that relabels the nuclei belonging to the same track with the
% same number
%stats3d = regionprops(newmask,inuc(:,:,1:4),'Centroid');
size(CC,2);           % number of zplanes
size(nucleilist,2);   % oved how many plane the niclei are spread
size(nucleilist,1);   % howmany objects were found in plane 1
badind = cellfun(@isempty,CC);
CC(badind) = [];

% from AW
% get the masks based on nuclei list
for ii = 1:length(CC)
    newplane = zeros(1024);
    for jj = 1:length(CC{ii}.PixelIdxList)
        newplane(CC{ii}.PixelIdxList{jj}) = jj;
    end
    trymask(:,:,ii) = newplane;
end
%  plot these
% for k =1:4
% figure(1),subplot(2,2,k); showMaskWithNumber(trymask(:,:,k));
% end
newmask = getGoodMask(trymask,nucleilist);

end

 
 
 
 
 
 