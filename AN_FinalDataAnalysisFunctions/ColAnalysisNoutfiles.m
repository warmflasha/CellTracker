%
% this function loads the colony structures from each of the matfiles
% corresponding to different quadrants = this gives colonies{k}, size of
% this cell array is Nplot ( the number of quadrants to plot)
% then a separate generalized function 'PlotColAnalysisQuadrAN' takes the
% colonies cell array for each quadrant,
% plots the fractions of gene-positive cells, gene-positive colonies and number of cells as a function of colony size 
% see also:  PlotColAnalysisFullChipAN
% 

function [totalcells] = ColAnalysisNoutfiles(Nplot,nms,thresh,nms2,param1,index1)
for k=1:Nplot
    
    filename = ['.' filesep  nms{k} '.mat'];
    load(filename);
    if exist('plate1');
        
        disp([filename,'plate1']);
        
        colonies{k} = plate1.colonies;
    else
        [colonies{k}, ~]=peaksToColonies(filename); % the choice to run either single cell or circular colony grouping is done within the peakstocolonies function
    end
    M(k) = max([colonies{k}.ncells]);
end
%---------------------------------------

[totalcells]=PlotColAnalysisQuadrAN(Nplot,colonies,M,thresh,nms2,param1,index1); % separate function which does the plotting



end