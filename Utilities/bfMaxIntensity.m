function max_img = bfMaxIntensity(reader,time,chan)


nz=reader.getSizeZ;


for ii=1:nz
    iPlane=reader.getIndex(ii - 1, chan -1, time - 1) + 1;
    img_now=bfGetPlane(reader,iPlane);
    if ii == 1
        max_img = img_now;
    else
        max_img = max(max_img,img_now);
    end
end

