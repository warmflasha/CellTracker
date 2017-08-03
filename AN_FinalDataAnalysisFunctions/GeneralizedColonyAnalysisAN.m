
% function to plot  the results of colony-size-dependent analysis.
% all the arguments are the same as described in the MMrunscriptsAN and
% 'plotallanalysisAN' function
% flag is 1 or zero, if 1, the the plots of the collony analysis will be
% shown, ig flag == 0, not shown;
% see also: plotallanalysisAN,MMrunscriptsAN


function [totalcells,ratios,ratios2,totcol] = GeneralizedColonyAnalysisAN(thresh,dir,nms,nms2,midcoord,fincoord,index1,param1,plottype,flag,dapimax,chanmax,dapiscalefactor)

if plottype == 0 % do NOT need to separate into quadrants
    for k=1:size(nms,2)        
        filename{k} = [dir filesep  nms{k} '.mat'];        
        load(filename{k},'plate1');
        colonies{k} = plate1.colonies;
        if ~exist('plate1','var')
            [colonies{k}, ~]=peaksToColonies(filename);
        end
        M(k) = max([colonies{k}.ncells]);        
    end
    M = max(M);
    [totalcells,ratios,ratios2,totcol] = PlotColAnalysisQuadrAN(colonies,M,thresh,nms2,param1,index1,flag,dapimax,chanmax,dapiscalefactor); % separate function which does the plotting
    
end
end
