function mkMaxIntensity(fileIn,fileOut)

reader = bfGetReader(fileIn);

nT = reader.getSizeT;
nC = reader.getSizeC;

for ii = 1:nT
    for jj = 1:nC     
        img(:,:,jj) =  bfMaxIntensity(reader,ii,jj);
    end
    if ii==1
        imwrite(img,fileOut,'Compression','none');
    else
        imwrite(img,fileOut,'writemode','append','Compression','none');
    end
end