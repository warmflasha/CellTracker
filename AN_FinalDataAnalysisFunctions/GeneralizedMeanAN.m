function [newdata] = GeneralizedMeanAN(nms2,index1,param1,toplot,peaks,plottype)
%  for k=1:Nplot
% disp(['loaded file: ' filename{k}]);
% end

if plottype == 1
    for k=1:size(toplot,2)
        
        peaksnew=[];
        for j=1:length(toplot{k})
            peaksnew{j} =  peaks{toplot{k}(j)};
            
        end
        [avgs, errs, alldat{k}]=Bootstrapping(peaksnew,100,1000,index1);
        newdata(k,1)=avgs;
        newdata(k,2)=errs;
    end
    figure (1),errorbar(newdata(:,1),newdata(:,2),'b*') ;
    
    set(gca,'Xtick',1:size(nms2,2));
    set(gca,'Xticklabel',nms2);
    limit2 = max(newdata(:,1))+1;
    ylim([0 limit2]);
    
    if size(index1) == 1
        ylabel(param1);
    else
        ylabel([param1,'/DAPI']);
    end
end

if plottype == 0
    for k=1:size(nms2,2)
        
        [avgs, errs, alldat{k}]=Bootstrapping(peaks,100,1000,index1);
        newdata(k,1)=avgs;
        newdata(k,2)=errs;
    end
    
    figure (1),errorbar(newdata(:,1),newdata(:,2),'b*') ;
    
    set(gca,'Xtick',1:size(nms2,2));
    set(gca,'Xticklabel',nms2);
    limit2 = max(newdata(:,1))+1;
    ylim([0 limit2]);
    
    if size(index1) == 1
        ylabel(param1);
    else
        ylabel([param1,'/DAPI']);
    end
end
end

