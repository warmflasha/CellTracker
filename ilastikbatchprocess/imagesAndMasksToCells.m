function cells=imagesAndMasksToCells(imgdirec,maskdirec,chan)

[~, imgfiles] = folderFilesFromKeyword(imgdirec,'.tif');
[~, maskfiles] = folderFilesFromKeyword(maskdirec,'Identi');

cells = [];
for tt = 1:2%length(imgfiles)
    
    
    imgreader = bfGetReader(fullfile(imgdirec, imgfiles(tt).name));
    maskreader = bfGetReader(fullfile(maskdirec,maskfiles(tt).name));
    
    
    mask_max = bfMaxIntensity(maskreader,1,1);
    
    cellmax = max(max(mask_max));
    
    nz = maskreader.getSizeZ;
    
    imsize = size(mask_max);
    
    mask = zeros(imsize(1),imsize(2),nz);
    
    nucimg = mask; smadimg = mask;
    
    for zz = 1:nz
        iplane = maskreader.getIndex(zz-1, 0, 0) + 1;
        mask(:,:,zz) = bfGetPlane(maskreader,iplane);
        
        iplane = imgreader.getIndex(0, chan(1), zz-1) + 1;
        
        nucimg(:,:,zz) = bfGetPlane(imgreader,iplane);
        
        iplane = imgreader.getIndex(0, chan(2), zz-1) + 1;
        
        smadimg(:,:,zz)=bfGetPlane(imgreader,iplane);
    end
    stats1 = regionprops(mask,nucimg,'Centroid','MeanIntensity');
    stats2 = regionprops(mask,smadimg,'MeanIntensity');
    for ii = 1:cellmax
        cellpix = mask == ii;
        if sum(sum(sum(cellpix))) > 0
            if length(cells) < ii || isempty(cells(ii))
                cells(ii).nucval = mean(nucimg(cellpix));
                cells(ii).smadval = mean(smadimg(cellpix));
                cells(ii).onframes = tt;
            else
                cells(ii).nucval = [cells(ii).nucval mean(nucimg(cellpix))];
                cells(ii).smadval =[cells(ii).smadval mean(smadimg(cellpix))];
                cells(ii).onframes =[cells(ii).onframes tt];
            end
            
        end
        
    end
end