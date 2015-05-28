
% plots the mean values, scatter plots and colony size-dependent analysis
% for the specified mat files (nms)
% specific for the case when you want to plot from several different outall
% mat files ( separate quadrants of the full cytoo chip with different
% experimental conditions or just different experiments overall
%
% see also: MMrunscriptsAN,MeanCytooQuadrants,ScatterPlotsCytooQuadrants,ColAnalysisNoutfiles

function [n,totalcells] = RunAnalysisQuadrantsAN(thresh,Nplot,nms,nms2,index1,index2,param1,param2)


n = MeanCytooQuadrants(Nplot,nms,nms2,index1,param1);

[~,~]=ScatterPlotsCytooQuadrants(Nplot,nms,nms2,index2,param1,param2);


[totalcells] = ColAnalysisNoutfiles(Nplot,nms,thresh,nms2,param1,index1);


end


  