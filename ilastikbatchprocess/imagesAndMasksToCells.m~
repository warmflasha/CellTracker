function cells=imagesAndMasksToCells(imgdirec,maskdirec,chan)

[~, imgfiles] = folderFilesFromKeyword(imgdirec,'.tif');
[~, maskfiles] = folderFilesFromKeyword(maskdirec,'Identi');


for tt = 1:length(imgfiles)


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
    mask(:,:,zz) = bfGetReader(maskreader,iplane);

    iplane = imgreader.getIndex(0, chan(1), zslice-1) + 1;

    nucimg(:,:,zz) = bfGetPlane(imgreader,iplane);

    iplane = imgreader.getIndex(0, chan(2), zslice-1) + 1;

    smadimg(:,:,zz)=bfGetPlane(imgreader,iplane);
end

for ii = 1:cellmax
    cellpix = mask == ii;
    if sum(sum(cellpix)) > 0
        if length(cells) < ii || isempty(cells(ii))
    cells(ii).nucval = mean(nucimg(cellpix));
    cells(ii).smadval = mean(smadimg(cellpix));
    cells(ii).onframe = tt;
        else
        cells(ii).nucval = mean(nucimg(cellpix));
    cells(ii).smad=smadval = mean(smadimg(cellpix));
    cells(ii).onframe = tt;
        end

end

end