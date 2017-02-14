function [ output_args ] = singleCells2Plots( singleCells )
%singleCells2Plots generates a few plots to quickly look at singleCells
%dataset
%   
global analysisParam;
% format time


% get ratios
colors = distinguishable_colors(analysisParam.nCon);

for iCon = 1:analysisParam.nCon;
    for iTime = find(~cellfun('isempty', singleCells{iCon}))
    nuc2nucMeans(iCon,iTime) = meannonan(singleCells{iCon}{iTime}(:,6)./singleCells{iCon}{iTime}(:,5));
    nuc2nucStd(iCon,iTime) = stdnonan(singleCells{iCon}{iTime}(:,6)./singleCells{iCon}{iTime}(:,5));
    nCells(iCon,iTime) = size(singleCells{iCon}{iTime},1);
    end
end
% plot nuc2nucMeans
figure; clf; hold on;
for iCon = 1:analysisParam.nCon;
plot(analysisParam.plotX(1:length(nuc2nucMeans)),nuc2nucMeans(iCon,:),'Color',colors(iCon,:),'LineWidth',2);
end
legend(analysisParam.conNames,'Location','best');
xlabel(['hours after ' analysisParam.ligandName ' added']);
ylabel([analysisParam.yMolecule ' : ' analysisParam.yNuc]);
title('mean signaling');

% plot mean with cell STD
figure; clf; hold on;
for iCon = 1:analysisParam.nCon;
errorbar(analysisParam.plotX(1:length(nuc2nucMeans)),nuc2nucMeans(iCon,:),nuc2nucStd(iCon,:),'Color',colors(iCon,:),'LineWidth',2);
end
legend(analysisParam.conNames,'Location','best');
xlabel(['hours after ' analysisParam.ligandName ' added']);
ylabel([analysisParam.yMolecule ' : ' analysisParam.yNuc]);
title('mean signaling w/ cell std');

% plot # of cells in each mean
figure; clf; hold on;
for iCon = 1:analysisParam.nCon;
plot(analysisParam.plotX(1:length(nuc2nucMeans)),nCells(iCon,:),'Color',colors(iCon,:),'LineWidth',2);
end
legend(analysisParam.conNames,'Location','eastoutside');
xlabel(['hours after ' analysisParam.ligandName ' added']);
ylabel('# of cells');
title('detected cells');

end

