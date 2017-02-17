function [ allChannelsRatios ] = allPeaks2ScatterPlot( allPeaks,channels )
%allPeaks2ScatterPlot plots a scatter plot of two normalized channels
% channels = two element vector containing the numbers of channels to be
% plotted. These are in order that they appear from left to right in peaks
% array not counting the nuc channel. (e.g., if fimg1 is usually colomn 6
% in peaks, it is indicated as 1 here)


global analysisParam;

allRatios = allPeaks2Ratios(allPeaks);





 
