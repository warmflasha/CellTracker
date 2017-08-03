function [newmask] = lblmask_2Dnuc(CC)
% CC , cell array contining the pixel idx and centroids

newplane = zeros(1024,1024);
for ii = 1:length(CC)    
    for jj = 1:length(CC(ii).PixelIdxList)
        newplane(CC(ii).PixelIdxList(jj)) = ii;
    end
    
end
newmask = newplane;

end