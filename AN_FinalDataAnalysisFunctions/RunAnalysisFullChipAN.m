
% plots the mean values, scatter plots and colony size-dependent analysis
% for the specified mat file (nms)
% specific for the case when you want to plot from single outall
% matfile (which was obtained from running the runfulltileMM on the full cytoo chip) but the conditions of experiments are different within the chip (Nplot parts of the chip are different)
% running this function will separate the conditions and plot mean values
% of expressed genes,scatter plots and perform colony size-dependent analysis
% 
% see also: MMrunscriptsAN,MeansFromQuadrantsOfFullChip,ScatterFromQuadrantsOfFullChip,ANColAnalysisFromFullChip

function [n,totalcells] = RunAnalysisFullChipAN(thresh,Nplot,nms,nms2,midcoord,fincoord,index1,index2,param1,param2)


n = MeansFromQuadrantsOfFullChip(Nplot,nms,nms2,midcoord,fincoord,index1,param1);

[~,~] = ScatterFromQuadrantsOfFullChip(Nplot,nms,nms2,midcoord,fincoord,index2,param1,param2);

totalcells = ANColAnalysisFromFullChip(Nplot,nms,thresh,nms2,param1,index1,midcoord,fincoord);


end