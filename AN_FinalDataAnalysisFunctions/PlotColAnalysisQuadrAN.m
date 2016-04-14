% plots the fractions of gene-positive cells, gene-positive colonies and number of cells as a function of colony size 
% 
% colonies is a cell array of colony data, separate for each of 
% quadrants/matfiles
% M is the maximum colony size from the given colony structure


function [totalcells,ratios,ratios2,totcol]=PlotColAnalysisQuadrAN(colonies,M,thresh,nms2,param1,index1,flag)
clear tmp

for k=1:size(nms2,2) % need to loop over the number of experimental conditions
    
    totalcolonies = zeros(M,1);
    genepositive = zeros(M,1);
    geneposcolonies = zeros(M,1);
    totalcells=zeros(M,1);
    
    
    for ii=1:size(colonies{k},2)
        if ~isempty(colonies{k}(ii).data);
            nc = colonies{k}(ii).ncells;
            
            totalcolonies(nc)=totalcolonies(nc)+1;
            if size(index1,2)==1
            tmp = colonies{k}(ii).data(:,index1(1))> thresh;
            end
            if size(index1,2)>1
            tmp = colonies{k}(ii).data(:,index1(1))./colonies{k}(ii).data(:,5) > thresh;
            end
            genepositive(nc)= genepositive(nc)+sum(tmp);
            geneposcolonies(nc)=geneposcolonies(nc)+any(tmp);
            
        end
    end
    %
    for l=1:length(totalcolonies)
        
        totalcells(l)=totalcolonies(l)*l;
        %totalcolonies(l) = totalcells(l)/l;
    end
   
    allcells = sum(totalcells);
    ratios{k} = genepositive./totalcells;
    ratios2{k} = geneposcolonies./totalcolonies;
     totcol{k} = totalcolonies;
    if flag == 1
    figure(3), subplot(1,size(nms2,2),k),  plot(ratios{k},'b*'); legend(nms2{k});
    xlabel('Number of cells in the colony');
    ylabel(['FractionOf',(param1),'PositiveCells']);
    title ([thresh]);
    xlim([0 10]);
    ylim([0 1]);
    
    figure(4),  subplot(1,size(nms2,2),k), plot(ratios2{k},'b*'); legend(nms2{k});
    xlabel('Number of cells in the colony');
    ylabel(['FractionOf',(param1),'PositiveColonies']);
    title ([thresh]);
    xlim([0 10]);
    ylim([0 1]);
    
    figure(5),  subplot(1,size(nms2,2),k), plot(totalcolonies,'b*'); legend(nms2{k}); % plot toalcolonies instead
    xlabel('Number of cells in the colony');
    ylabel('Total COlonies');
    title ([thresh]);
    xlim([0 15]);
    end
    
end

end