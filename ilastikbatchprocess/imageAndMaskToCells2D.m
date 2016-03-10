function cells = imageAndMaskToCells2D(imagestack,trackstack,chan)

imgreader = bfGetReader(imagestack);
maskreader = bfGetReader(trackstack);

nT = maskreader.getSizeT;

cells =[];

for tt = 1:nT
    disp(['frame: ' int2str(tt)]);
    iplane = maskreader.getIndex(0, 0, tt - 1) + 1;
    mask = bfGetPlane(maskreader,iplane);
    
    cellmax = max(max(mask));
    
    iplane = imgreader.getIndex(tt - 1, chan(1), 0) + 1;
    
    nucimg = bfGetPlane(imgreader,iplane);
    
    iplane = imgreader.getIndex(tt - 1, chan(2), 0) + 1;
    
    smadimg=bfGetPlane(imgreader,iplane);
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