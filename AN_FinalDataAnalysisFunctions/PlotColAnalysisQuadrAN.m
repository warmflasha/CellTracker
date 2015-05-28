% plots the fractions of gene-positive cells, gene-positive colonies and number of cells as a function of colony size 
% see also:  PlotColAnalysisFullChipAN
% colonies is a cell array of colony data, separate for each of Nplot
% quadrants/matfiles


function [totalcells]=PlotColAnalysisQuadrAN(Nplot,colonies,M,thresh,nms2,param1,index1)



for k=1:Nplot
    
    totalcolonies = zeros(M(k),1);
    genepositive = zeros(M(k),1);
    geneposcolonies = zeros(M(k),1);
    
    totalcells=zeros(M(k),1);
    
    % colonies{k} = col;
    
    for ii=1:size(colonies{k},2)
        if ~isempty(colonies{k}(ii).data);
            nc = colonies{k}(ii).ncells;
            
            totalcolonies(nc)=totalcolonies(nc)+1;
            %totalcells(nc)=totalcells(nc)+nc;
            tmp = colonies{k}(ii).data(:,index1(1))./colonies{k}(ii).data(:,5) > thresh;
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