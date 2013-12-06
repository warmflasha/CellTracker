function runAviFiles(nucAvi,smadAvi,outfile)

nuc_mov=VideoReader(nucAvi);
S4_mov=VideoReader(smadAvi);

for ii=1:nuc_mov.NumberOfFrames
    nuc=read(nuc_mov,ii);
    nuc=nuc(:,:,1);
    fimg=read(S4_mov,ii);
    fimg=fimg(:,:,2);
    [maskC, statsN]=segmentCells(nuc,fimg);
    [~, statsN]=addCellAvr2Stats(maskC,fimg,statsN);
    outdat=outputData4AWTracker(statsN,nuc,1);
    peaks{ii}=outdat;
end

pictimes = 1:nuc_mov.NumberOfFrames;

save(outfile,'pictimes','peaks');