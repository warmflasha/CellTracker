function statsN = ilastikMaskToStats(mask)
%gets some stats from mask
 
cc_struct = bwconncomp(mask);
statsN = regionprops(cc_struct, 'PixelIdxList', 'Centroid');
for ii = 1:length(statsN)
    statsN(ii).PixelIdxList = statsN(ii).PixelIdxList';
end
    