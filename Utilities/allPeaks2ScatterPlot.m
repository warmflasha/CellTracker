function [ allChannelsRatios ] = allPeaks2ScatterPlot( allPeaks,channels,conditions )
%allPeaks2ScatterPlot plots a scatter plot of two normalized channels
% channels = two element vector containing the numbers of channels to be
% plotted. These are in order that they appear from left to right in peaks
% array not counting the nuc channel. (e.g., if fimg1 is usually colomn 6
% in peaks, it is indicated as 1 here)

% conditions = vector containing the conditions to plot




global analysisParam;
colors = distinguishable_colors(analysisParam.nCon);
tempColors = distinguishable_colors(4);
colors([1 4 9 10],:) =  tempColors;


allRatios = allPeaks2Ratios(allPeaks);
allRatios = allPeaks2singleCells(allRatios);
figure; hold on;
for iCon = conditions;
    plot(allRatios{iCon}(:,channels(1)),allRatios{iCon}(:,channels(2)),'.','Color',colors(iCon,:))
end
legend(analysisParam.conNames(conditions),'Location','best');
xlabel(analysisParam.channelNames(channels(1)));
ylabel(analysisParam.channelNames(channels(2)));





 
