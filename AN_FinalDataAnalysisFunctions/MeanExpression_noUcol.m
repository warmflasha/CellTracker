function [newdata] = MeanExpression_noUcol(nms,nms2,dir,midcoord,fincoord,index1,param1,plottype,flag,dapimax, chanmax)
% rescale dapi
dapi= [];
colormap = prism;
for k=1:size(nms2,2)
[dapi(k),ncells] = getmeandapi(nms(k),dir,index1, dapimax);
disp(['cells found' num2str(ncells) ]);
end
dapiscalefactor = dapi/dapi(1);
if plottype == 0
    for k=1:size(nms,2)        % load however many files are in the nms string
        filename{k} = [dir filesep  nms{k} '.mat'];
        load(filename{k},'peaks','plate1');
        %disp(['loaded file: ' filename{k}]);
 % get dapimean
        [avgs, errs, alldat{k}]=Bootstrap_noUcol(peaks,100,1000,index1,dapimax, chanmax);
        newdata(k,1)=avgs./(dapi(k)*dapiscalefactor(k));%(dapi(k)*dapiscalefactor(k))
        newdata(k,2)=errs./(dapi(k)*dapiscalefactor(k));%(dapi(k)*dapiscalefactor(k))
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