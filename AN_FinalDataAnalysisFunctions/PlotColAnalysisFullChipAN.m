% 
%function to plot the fraction of genepositive cells vs colony size
% genepositive colonies as a function of colony size and colony size
% distribution
% input
% coloniesnew = the cell array of size Nplot; contains the colony data specific to each quadrant.
% M -the size of the largest colony, used to initialize the size of the
% vectors to be filled.
% see also: ANColAnalysisFromFullChip

function [totalcells]=PlotColAnalysisFullChipAN(Nplot,coloniesnew,M,thresh,nms2,param1,index1)



for k=1:Nplot
    
    totalcolonies = zeros(M,1);
    genepositive = zeros(M,1);
    geneposcolonies = zeros(M,1);
    
    totalcells=zeros(M,1);
    
    % coloniesnew{k} = col;
    
    for ii=1:size(coloniesnew{k},2)
        if ~isempty(coloniesnew{k}(ii).data);
            nc = coloniesnew{k}(ii).ncells;
            
            totalcolonies(nc)=totalcolonies(nc)+1;
            %totalcells(nc)=totalcells(nc)+nc;
            tmp = coloniesnew{k}(ii).data(:,index1(1))./coloniesnew{k}(ii).data(:,5) > thresh;
            genepositive(nc)=genepositive(nc)+sum(tmp);
            geneposcolonies(nc)=geneposcolonies(nc)+any(tmp);
            
        end
    end
    %
    for l=1:length(totalcolonies)
        
        totalcells(l)=totalcolonies(l)*l;
    end
    
    allcells = sum(totalcells);
    ratios = genepositive./totalcells;
    ratios2 = geneposcolonies./totalcolonies;
    
    
    figure(3), subplot(2,2,k),  plot(ratios,'b*'); legend(nms2{k});
    xlabel('Number of cells in the colony');
    ylabel(['FractionOf',(param1),'PositiveCells']);
    title ([thresh]);
    xlim([0 10]);
    ylim([0 1]);
    
    figure(4),  subplot(2,2,k), plot(ratios2,'b*'); legend(nms2{k});
    xlabel('Number of cells in the colony');
    ylabel(['FractionOf',(param1),'PositiveColonies']);
    title ([thresh]);
    xlim([0 10]);
    ylim([0 1]);
    
    figure(5),  subplot(2,2,k), plot(totalcells,'b*'); legend(nms2{k});
    xlabel('Number of cells in the colony');
    ylabel('Total cells');
    title ([thresh]);
    xlim([0 15]);
    
end

end