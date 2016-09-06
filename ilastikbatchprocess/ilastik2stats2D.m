function stats = ilastik2stats2D(h5file,imgfile)

if ischar(h5file)
    mask1 = readIlastikFile(h5file);
else
    mask1 = h5file;
end

stats = ilastikMaskToStats(mask1);

if ischar(imgfile)
    reader = bfGetReader(imgfile);
    nc = reader.getSizeC;
    nz = 1; 
    img =zeros(reader.getSizeX,reader.getSizeY,nz);
else
    img = imgfile;
    nc = size(img,3);
end





for cc=1:nc
    if ischar(imgfile)
        for ii=1:nz
            iplane=reader.getIndex(ii - 1, cc -1, 0) + 1;
            img(:,:,ii) = bfGetPlane(reader,iplane);
        end
    end
    stats_tmp = regionprops(mask1,img(:,:,cc),'MeanIntensity');
    for jj = 1:length(stats)
        stats(jj).MeanIntensity(cc) = stats_tmp(jj).MeanIntensity;
    end
end

