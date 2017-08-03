function plotscatter(chandata,nms2,toplot,N,i1,i2,i3,paramstr,normto)

colormap = colorcube;
if ~isempty(N)
    for k=1:size(toplot,2)
         if ~isempty(normto)
        figure(20),scatter((chandata{toplot(k)}(1:N:end,i1)./chandata{toplot(k)}(1:N:end,normto)),(chandata{toplot(k)}(1:N:end,i2)./chandata{toplot(k)}(1:N:end,normto)),[],(chandata{toplot(k)}(1:N:end,i3)./chandata{toplot(k)}(1:N:end,normto)));hold on%,'Color','c','LineWidth',3chandata{k}(:,j)./chandata{k}(:,normto),chandata{k}(:,xx)./chandata{k}(:,cyt)
         end
        if isempty(normto)
       figure(20),scatter(chandata{toplot(k)}(1:N:end,i1),chandata{toplot(k)}(1:N:end,i2),[],chandata{toplot(k)}(1:N:end,i3));hold on%,'Color','c','LineWidth',3chandata{k}(:,j)./chandata{k}(:,normto),chandata{k}(:,xx)./chandata{k}(:,cyt)
        end
        h = figure(20);box on
        h.CurrentAxes.LineWidth = 3; h.CurrentAxes.FontSize = 20;
        h.Colormap = jet;
        ylabel(paramstr{i2});
        xlabel(paramstr{i1});
        colorbar
    end
    legend(nms2(toplot))
    title(['Plot every ' num2str(N) ' th point']);
end
if isempty(N)
    for k=1:size(toplot,2)
         
        if ~isempty(normto)
        figure(20),scatter((chandata{toplot(k)}(:,i1)./chandata{toplot(k)}(:,normto)),(chandata{toplot(k)}(:,i2)./chandata{toplot(k)}(:,normto)),[],(chandata{toplot(k)}(:,i3)./chandata{toplot(k)}(:,normto)));hold on%,'Color','c','LineWidth',3chandata{k}(:,j)./chandata{k}(:,normto),chandata{k}(:,xx)./chandata{k}(:,cyt)
        end
        if isempty(normto)
        figure(20),scatter(chandata{toplot(k)}(:,i1),chandata{toplot(k)}(:,i2),[],(chandata{toplot(k)}(:,i3)));hold on%,'Color','c','LineWidth',3chandata{k}(:,j)./chandata{k}(:,normto),chandata{k}(:,xx)./chandata{k}(:,cyt)
        end
        h = figure(20);box on
        h.CurrentAxes.LineWidth = 3; h.CurrentAxes.FontSize = 20;
        h.Colormap = jet;
        ylabel(paramstr{i2});
        xlabel(paramstr{i1});
        colorbar
        
    end
    legend(nms2(toplot));
    
end
end