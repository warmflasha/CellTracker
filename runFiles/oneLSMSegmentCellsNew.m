function [outdat, tt]=oneLSMSegmentCellsNew(lsmfile,chan)


global userParam;
tt=bfopen(lsmfile);

nuc=tt{1}{chan(1),1};

nuc = smoothImage(nuc,userParam.gaussRadius,userParam.gaussSigma);
for ii=2:length(chan)
    fimg(:,:,ii-1)=tt{1}{chan(ii),1};
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