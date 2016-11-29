function [findat] = MeanDecomposedbyColAN(nms,nms2,dir,index1,param1,dapimax,N)

%clear findat
meanN = zeros(size(nms,2),1);
err = zeros(size(nms,2),1);
nonNorm = zeros(size(nms,2),1);
for k=1:size(nms,2)        % load however many files are in the nms string
    filename{k} = [dir filesep  nms{k} '.mat'];
    load(filename{k},'peaks','plate1');
    disp(['loaded file: ' filename{k}]);
    col = plate1.colonies;
    
    for ii=1:length(col)
        
        ncell = size(col(ii).data,1);
        if ncell == N
            b = col(ii).data(:,index1(1))./col(ii).data(:,5);%  col(ii).data(any(col(ii).data(:,5) > dapimax),5)
            junkdapi = (col(ii).data(:,5) > dapimax);
            b(junkdapi) = [];
            non = col(ii).data(:,index1(1));
            non(junkdapi) = [];
            
            meanN(k,1)=mean(b);
            err(k,1)=std(b);
            nonNorm(k,1)=mean(non);
            
        end
        
        
    end
end
findat = cat(2,meanN,err,nonNorm);

figure(7),errorbar(findat(:,1),findat(:,2),'-*','markersize',12,'linewidth',2) ;

set(gca,'Xtick',1:size(nms2,2));
set(gca,'Xticklabel',nms2);
limit2 = max(findat(:,1))+4;
ylim([0 limit2]);
ylabel([param1,'/meanDAPI']);
title(['Mean expression for colonies of size ' num2str(N)]);
% %plot unnormalized values
% figure(8),plot(findat(:,3),'r*','markersize',12,'linewidth',2) ;
% set(gca,'Xtick',1:size(nms2,2));
% set(gca,'Xticklabel',nms2);
% limit2 = max(findat(:,3))+100;
% ylim([0 limit2]);
% ylabel([param1,'Unnormalized']);
% title(['Mean expression for colonies of size ' num2str(N)]);
end
