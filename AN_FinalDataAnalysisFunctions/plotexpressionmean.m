function [chandata]=plotexpressionmean(dir,nms,nms2,paramstr,vect,normto,index,titlestr)
 
 C = {'r','g','c','m'}; 
 [chandata]= rawdatainchan(nms,dir,index); 
 
 meanval = zeros(size(nms2,2),size(index,2));
 err = zeros(size(nms2,2),size(index,2));
 if~isempty(normto)
 for j=1:size(index,2)
 for k=1:size(nms,2) 
     sz1 = size(chandata{k}(:,j)./chandata{k}(:,normto),1);
     meanval(k,j) = mean(chandata{k}(:,j)./chandata{k}(:,normto));
     err(k,j) = std(chandata{k}(:,j)./chandata{k}(:,normto))./power(sz1,0.5);
 end
 end
 for j=2:size(index,2)   
 figure(j),errorbar(vect,meanval(:,j),err(:,j),'p','MarkerFaceColor',C{j},'MarkerEdgeColor',C{j},'MarkerSize',18,'LineWidth',2);hold on%,'Color','c','LineWidth',3chandata{k}(:,j)./chandata{k}(:,normto),chandata{k}(:,xx)./chandata{k}(:,cyt)
  hh = figure(j);
 hh.CurrentAxes.XTickLabel=nms2;
 hh.CurrentAxes.LineWidth = 3; hh.CurrentAxes.FontSize = 18;  
 hh.CurrentAxes.XTick = vect;
 hh.CurrentAxes.XScale= 'linear';
 hh.CurrentAxes.XLim = [0 max(vect)+1];
 hh.CurrentAxes.YLim = [0 max(meanval(:,j))+0.3];
 hh.CurrentAxes.XTickLabelRotation = 35; box on
 ylabel('Mean expression, a.u.'); 
 legend(paramstr{j});
 title(titlestr);

 end
 end
 if isempty(normto)
  C = {'r','g','c','m'}; 
 [chandata]= rawdatainchan(nms,dir,index);  
 meanval = zeros(size(nms2,2),size(index,2));
 err = zeros(size(nms2,2),size(index,2));
 for j=1:size(index,2)
 for k=1:size(nms,2) 
     sz1 = size(chandata{k}(:,j),1);
     meanval(k,j) = mean(chandata{k}(:,j));
     err(k,j) = std(chandata{k}(:,j))./power(sz1,0.5);
 end
 end
 for j=2:size(index,2)   
 figure(j),errorbar(vect,meanval(:,j),err(:,j),'-p','MarkerFaceColor',C{j},'MarkerEdgeColor',C{j},'MarkerSize',18,'LineWidth',2);hold on%,'Color','c','LineWidth',3chandata{k}(:,j)./chandata{k}(:,normto),chandata{k}(:,xx)./chandata{k}(:,cyt)
  hh = figure(j);
 hh.CurrentAxes.XTickLabel=nms2;
 hh.CurrentAxes.LineWidth = 3; hh.CurrentAxes.FontSize = 18;  
 hh.CurrentAxes.XTick = vect;
 hh.CurrentAxes.XScale= 'linear';
 hh.CurrentAxes.XLim = [0 max(vect)+1];
 hh.CurrentAxes.YLim = [0 max(meanval(:,j))+0.3];
 hh.CurrentAxes.XTickLabelRotation = 35; box on
 ylabel('Mean expression, a.u.'); 
 legend(paramstr{j});
 figure(j),title(titlestr);
 end   
     
     
     
 end
 