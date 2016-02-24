function max_img = bfMaxIntensity(reader,time,chan,bitdepth)


nz=reader.getSizeZ;


for ii=1:nz
    iPlane=reader.getIndex(ii - 1, chan -1, time - 1) + 1;
    img_now=bfGetPlane(reader,iPlane);
    
    if exist('bitdepth','var')
        switch bitdepth
            case 8
                img_now = uint8(img_now);
            case 16
                img_now = uint16(img_now);
            otherwise
                disp('bitdepth must be 8 or 16');
        end
                
    end
    if ii == 1
        max_img =  img_now;
    else
        max_img = max(max_img,img_now);
    end
end

