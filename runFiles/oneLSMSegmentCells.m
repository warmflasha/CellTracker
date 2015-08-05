function [outdat, tt]=oneLSMSegmentCells(lsmfile,chan)

tt=tiffread27(lsmfile);
[tmp, suf]=strtok(lsmfile,'.');
if strcmp(suf,'.lsm')
    nuc=tt.data{chan(1)};
    for ii=2:length(chan)
        fimg(:,:,ii-1)=tt.data{chan(ii)};
    end
else
    nuc=tt(chan(1)).data;
    for ii=2:length(chan)
        fimg(:,:,ii-1)=tt(chan(ii)).data;
    end
end
[maskC, statsN]=segmentCells2(nuc,fimg);
[~, statsN]=addCellAvr2Stats(maskC,fimg,statsN);
outdat=outputData4AWTracker(statsN,nuc,length(chan)-1);
% for jj=3:length(chan)
%     if strcmp(suf,'.lsm')
%         fimg=tt.data{chan(jj)};
%     else
%         fimg=tt(chan(jj)).data;
%     end
%     [maskC statsN]=segmentCells(nuc,fimg);
%     [~, statsN]=addCellAvr2Stats(maskC,fimg,statsN);
%     outdat2=outputData4AWTracker(statsN,nuc,1);
%     outdat=[outdat outdat2(:,6:7)];
% end