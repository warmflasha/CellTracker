function mkMaxIntensity(fileIn,fileOut)

reader = bfGetReader(fileIn);

nT = reader.getSizeT;
nC = reader.getSizeC;

if nC == 2;
    sX = reader.getSizeX;
    sY = reader.getSizeY;
    empty = zeros(sY,sX);
    disp('Detected only 2 channels, third channel will be empty.');
end


for ii = 1:nT
    for jj = 1:nC
        img(:,:,jj) =  bfMaxIntensity(reader,ii,jj);
    end
    if nC == 2
        img(:,:,3) = empty;
    end
    if ii==1
        imwrite(img,fileOut,'Compression','none');
    else
        imwrite(img,fileOut,'writemode','append','Compression','none');
    end
    
end