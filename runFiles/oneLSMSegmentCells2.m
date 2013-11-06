function [outdat tt]=oneLSMSegmentCells2(lsmfile,chan)


tt=imread(lsmfile);

nuc=tt(:,:,chan(1));
fimg=tt(:,:,chan(2));
[maskC statsN]=segmentCells(nuc,fimg);
[~, statsN]=addCellAvr2Stats(maskC,fimg,statsN);
outdat=outputData4AWTracker(statsN,nuc,1);
for jj=3:length(chan)
    fimg=tt(:,:,chan(jj));
    [maskC statsN]=segmentCells(nuc,fimg);
    [~, statsN]=addCellAvr2Stats(maskC,fimg,statsN);
    outdat2=outputData4AWTracker(statsN,nuc,1);
    outdat=[outdat outdat2(:,6:7)];
end