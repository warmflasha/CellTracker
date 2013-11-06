function [avgreturn pictimes]=mkAveragePlot(matfile,plotcols,includefeedings,ps,mkhandle,mklegend)
%function avgreturn=mkAveragePlot(matfile,includefeedings,ps,mkhandle)
%--------------------------------------------------------------
%function to plot average fluor as a function of time for tracked
%timelapse.
%matfile -- matfile with data.
%plotcols -- columns to use. if 1 entry in vector, plot this column. If two
%entries plot ratio. If 2 identical entries, plot column normalized to
%first time point
%ps (optional) -- plot style. default ps='k.-'
%includefeeding (optional) -- 0/1. make vertical lines corresponding to
%               feeding times colored by medianum. default 1.
%mkhandle (optional) -- 0/1 . mkhandle=1 will make curve show up in legend. 
%                              default mkhandle=1

if ~exist('plotcols','var') || isempty(plotcols)
    plotcols=[6 7];
end
if ~exist('mklegend','var')
    mklegend=0;
end
if ~exist('ps','var') || isempty(ps)
    ps='k.-';
end
if ~exist('mkhandle','var')
    mkhandle=1;
end
if ~exist('includefeedings','var')
    includefeedings=1;
end
if includefeedings
    load(matfile,'cells','feedings','pictimes');
else
    load(matfile,'cells','pictimes');
    feedings=[];
end
avgreturn=averagePlot(cells,plotcols,pictimes,feedings,ps,mkhandle,mklegend);

