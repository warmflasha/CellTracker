function finalMask = simpleSegmentation(img,cellArea,cellIntensity,separateFused)

global userParam;

cellSize = sqrt(cellArea/pi);
userParam.gaussRadius = floor(cellSize/6);
userParam.gaussSigma = floor(cellSize/18);
userParam.presubNucBackground = 1;
userParam.backdiskrad = round(cellSize*2);
erodeSize = 1.2;
cellarea = (cellSize/2)^2*pi;

img_proc = preprocessImages(img);
mask = img_proc > cellIntensity;

mask = imfill(mask,'holes');
mask = bwareaopen(mask,2*floor(cellarea/3));



if separateFused
    CC = bwconncomp(mask);
    stats = regionprops(CC, 'Area');
    area = [stats.Area];
    fusedCandidates = area > 1.7*cellarea;
    
    sublist = CC.PixelIdxList(fusedCandidates);
    sublist = cat(1,sublist{:});
    
    fusedMask = false(size(mask));
    fusedMask(sublist) = 1;
    
    s = round(erodeSize*cellSize/3);
    nucmin = imerode(fusedMask,strel('disk',s));
    
    % dilation by 1 pixel because otherwise the distance on the edge is
    % zero so the mask is shrunk by 1 pixel
    outside = ~imdilate(fusedMask,strel('disk',1));
    basin = imcomplement(bwdist(outside));
    basin = imimposemin(basin, nucmin | outside);
    
    L = watershed(basin);
    finalMask = L > 1 | mask - fusedMask;
else
    finalMask = mask;
end

%finalMask = imclose(finalMask,strel('disk',floor(cellSize/6)));

