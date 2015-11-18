function saveOneZstack(reader,outfile,time,chan)

nz=reader.getSizeZ;


for ii=1:nz
    for jj=1:length(chan)
        iPlane=reader.getIndex(ii - 1, chan(jj) -1, time - 1) + 1;
        img(:,:,jj)=bfGetPlane(reader,iPlane);
    end
    if size(img,3) == 2
        img(:,:,3)=zeros(size(img(:,:,1)));
    end
    
    if ii==1
        imwrite(img,outfile,'Compression','none');
    else
        imwrite(img,outfile,'writemode','append','Compression','none');
    end
end

