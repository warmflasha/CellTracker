function cells=imagesAndMasksToCells(imgdirec,maskdirec,chan,frames)

[~, imgfiles] = folderFilesFromKeyword(imgdirec,'.tif');
[~, maskfiles] = folderFilesFromKeyword(maskdirec,'Tracking');

cells = [];
if ~exist('frames','var')
    frames = 1:length(imgfiles);
end

for tt = frames
    
    disp(['Frame: ' int2str(tt)]);
    imgreader = bfGetReader(fullfile(imgdirec, imgfiles(tt).name));
    maskreader = bfGetReader(fullfile(maskdirec,maskfiles(tt).name));
    
    mask_max = bfMaxIntensity(maskreader,1,1,16);
    
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
    stats1 = regionprops(mask,nucimg,'Area','Centroid','MeanIntensity');
    stats2 = regionprops(mask,smadimg,'MeanIntensity');
    
    
    
    for ii = 1:cellmax
        %cellpix = mask == ii;
        if stats1(ii).Area > 0
            stats1(ii).fluordata = [stats1(ii).MeanIntensity stats2(ii).MeanIntensity 0];
            if length(cells) < ii || isempty(cells(ii))
                if isempty(cells)
                    cells = dynCell(stats1(ii),tt);
                else
                    cells(ii) = dynCell(stats1(ii),tt);
                end
            else
                cells(ii) = cells(ii).addTimeToCell(stats1(ii),tt);
            end
            
        end
    end
end