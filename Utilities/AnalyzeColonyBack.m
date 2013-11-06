function [IntCell analyzed]=AnalyzeColonyBack(matfile,firstframe,lastframe)

load(matfile,'peaks','cells');
cellnums=peaks{lastframe}(:,8);
cellnums= cellnums(cellnums > 0);

timestep=1; radius=40;
for ii=1:length(cellnums)
    disp(int2str(ii));
    [afd posarray]=mfIntegrateOneCellBack(cells,peaks,cellnums(ii),firstframe,lastframe,timestep,radius);
    IntCell(ii).IntegratedFluor=afd;
    IntCell(ii).IntegratedPos=posarray;
    IntCell(ii).cellNum=cellnums(ii);
end

for ii=1:length(IntCell)
    rmax=max(IntCell(ii).IntegratedFluor(:,2)./IntCell(ii).IntegratedFluor(:,3));
    fposind=find(abs(IntCell(ii).IntegratedPos(:,1)) > 0,1,'last');
    ffluorind=find(~isnan(IntCell(ii).IntegratedFluor(:,1)),1,'last');
    endr=IntCell(ii).IntegratedFluor(ffluorind,2)/IntCell(ii).IntegratedFluor(ffluorind,1);
    analyzed(ii,:)=[IntCell(ii).IntegratedPos(1,:) IntCell(ii).IntegratedPos(fposind,:) rmax endr];
end

save(matfile,'IntCell','-append');


