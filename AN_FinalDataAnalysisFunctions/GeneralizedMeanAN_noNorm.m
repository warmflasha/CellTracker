function [newdata] = GeneralizedMeanAN_noNorm(nms,nms2,dir,midcoord,fincoord,index1,param1,plottype,flag,dapimax, chanmax)
dapi= [];
colormap = prism;
for k=1:size(nms2,2)
[dapi(k),ncells] = getmeandapi(nms(k),dir,index1, dapimax);
disp(['cells found' num2str(ncells) ]);
disp(['dapi mean value' num2str(dapi(k)) ]);

end
dapiscalefactor = dapi/dapi(1);
dapiscalefactor = ones(1,size(nms,2));
disp(dapiscalefactor);
if plottype == 0
    for k=1:size(nms,2)        % load however many files are in the nms string
        filename{k} = [dir filesep  nms{k} '.mat'];
        load(filename{k},'peaks');
        %disp(['loaded file: ' filename{k}]);
 % get dapimean
        [avgs, errs, alldat{k}]=Bootstrapping(peaks,100,1000,index1(1),dapimax, chanmax,[]);
        newdata(k,1)=avgs;
        newdata(k,2)=errs;        
            
    end    
    if flag == 1      
    figure(1),errorbar(newdata(:,1),newdata(:,2),'g-*','markersize',16,'linewidth',3) ;
    set(gca,'Xtick',1:size(nms2,2));
    set(gca,'Xticklabel',nms2);
    limit2 = max(newdata(:,1))+0.5;
    ylim([0 limit2]);    
    if size(index1) == 1
        ylabel(param1);
    else
        ylabel([param1,'/DAPI']);
    end
    end   
end
end