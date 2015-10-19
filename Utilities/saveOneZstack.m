function saveOneZstack(reader,outfile,time,chan)

nz=reader.getSizeZ;


for ii=1:nz
    iPlane=reader.getIndex(ii - 1, chan -1, time - 1) + 1;
    img=bfGetPlane(reader,iPlane);
    if ii==1
        imwrite(img,outfile,'Compression','none');
    else
        imwrite(img,outfile,'writemode','append','Compression','none');
    end
end

