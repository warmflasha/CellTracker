function plotscatter(chandata,nms2,toplot,N,i1,i2,i3,paramstr,normto,samplot)

colormap = colorcube;
if ~isempty(N)
    for k=1:size(toplot,2)
         if ~isempty(normto)
        figure(20),scatter((chandata{toplot(k)}(1:N:end,i1)./chandata{toplot(k)}(1:N:end,normto)),(chandata{toplot(k)}(1:N:end,i2)./chandata{toplot(k)}(1:N:end,normto)),[],colormap(randi(40),:));hold on%,'Color','c','LineWidth',3chandata{k}(:,j)./chandata{k}(:,normto),chandata{k}(:,xx)./chandata{k}(:,cyt)
         end
        if isempty(normto)
       figure(20),scatter(chandata{toplot(k)}(1:N:end,i1),chandata{toplot(k)}(1:N:end,i2),[],colormap(randi(40),:));hold on%,'Color','c','LineWidth',3chandata{k}(:,j)./chandata{k}(:,normto),chandata{k}(:,xx)./chandata{k}(:,cyt)
        end
        h = figure(20);box on
        h.CurrentAxes.LineWidth = 3; h.CurrentAxes.FontSize = 20;
        h.Colormap = jet;
        ylabel(paramstr{i2});
        xlabel(paramstr{i1});
       
    end
    legend(nms2(toplot))
    title(['Plot every ' num2str(N) ' th point']);
end
if isempty(N) && size(toplot,2)==1
    for k=1:size(toplot,2)
         
        if ~isempty(normto)
        figure(20),scatter((chandata{toplot(k)}(:,i1)./chandata{toplot(k)}(:,normto)),(chandata{toplot(k)}(:,i2)./chandata{toplot(k)}(:,normto)),[],colormap(randi(40),:));hold on%,'Color','c','LineWidth',3chandata{k}(:,j)./chandata{k}(:,normto),chandata{k}(:,xx)./chandata{k}(:,cyt)
        end
        if isempty(normto)
        figure(20),scatter(chandata{toplot(k)}(:,i1),chandata{toplot(k)}(:,i2),[],(chandata{toplot(k)}(:,i3)));hold on%,'Color','c','LineWidth',3chandata{k}(:,j)./chandata{k}(:,normto),chandata{k}(:,xx)./chandata{k}(:,cyt)
        end
        h = figure(20);box on
        h.CurrentAxes.LineWidth = 3; h.CurrentAxes.FontSize = 20;
        h.Colormap = jet;
        ylabel(paramstr{i2});
        xlabel(paramstr{i1});
        
        
    end
    legend(nms2(toplot));
    
end
if size(toplot,2)>1 && (isempty(N))
    for k=1:size(toplot,2)
         
        if ~isempty(normto)
        figure(20),scatter(chandata{toplot(k)}(:,i1)./chandata{toplot(k)}(:,normto),chandata{toplot(k)}(:,i2)./chandata{toplot(k)}(:,normto),[],colormap(randi(40),:));hold on%,'Color','c','LineWidth',3chandata{k}(:,j)./chandata{k}(:,normto),chandata{k}(:,xx)./chandata{k}(:,cyt)
        end
        if isempty(normto)
        figure(20),scatter(chandata{toplot(k)}(:,i1),chandata{toplot(k)}(:,i2),[],colormap(randi(20),:));hold on%,'Color','c','LineWidth',3chandata{k}(:,j)./chandata{k}(:,normto),chandata{k}(:,xx)./chandata{k}(:,cyt)
        end
        h = figure(20);box on
        h.CurrentAxes.LineWidth = 3; h.CurrentAxes.FontSize = 20;
        %h.Colormap = jet;
        ylabel(paramstr{i2});
        xlabel(paramstr{i1});
        
        
    end
    legend(nms2(toplot));
    
    
    
end 
if samplot == 0
    close all
     for k=1:size(toplot,2)
         
        if ~isempty(normto)
        figure(k),scatter((chandata{toplot(k)}(:,i1)./chandata{toplot(k)}(:,normto)),(chandata{toplot(k)}(:,i2)./chandata{toplot(k)}(:,normto)),[],colormap(randi(40),:));hold on%,'Color','c','LineWidth',3chandata{k}(:,j)./chandata{k}(:,normto),chandata{k}(:,xx)./chandata{k}(:,cyt)
        end
        if isempty(normto)
        figure(k),scatter(chandata{toplot(k)}(:,i1),chandata{toplot(k)}(:,i2),[],colormap(randi(20),:));hold on%,'Color','c','LineWidth',3chandata{k}(:,j)./chandata{k}(:,normto),chandata{k}(:,xx)./chandata{k}(:,cyt)
        end
        h = figure(k);box on
        h.CurrentAxes.LineWidth = 3; h.CurrentAxes.FontSize = 20;
        %h.Colormap = jet;
        ylabel(paramstr{i2});
        xlabel(paramstr{i1});
        
        legend(nms2(toplot(k)));
        xlim([0 5])
        ylim([0 5])
    end
    
    
    
end


    
end