function [maskzcyto_lbl] = GetVoronoiCells2D(newmask,pmaskscyto)

clear dist
clear nuc_submask
% mask1test = (newmask(:,:,1)==2);
% dist = bwdist(mask1test);
nelem = max(max(newmask)); %number of elements in all masks
%get the number of cells
for j=1:nelem
    nuc_submask(:,:,:,j) = newmask==j;
    dist(:,:,:,j) = bwdist(nuc_submask(:,:,:,j));
end
[~, min_ind]=min(dist,[],4);
min_ind(pmaskscyto == 0) = 0;
%min_ind(newmask > 0) = 0;          % need to do this later, need the filled
                                    %labeled mask, in order to remove cytoplasms without the nucleus
maskzcyto_lbl = min_ind;
end