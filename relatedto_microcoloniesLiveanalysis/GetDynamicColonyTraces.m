function GetDynamicColonyTraces(matfile,fr_stim,fldat,delta_t)
% plots cell traces for all identified coonies
% separate figure for each colony

load(matfile,'colonies','ncells');

p = fr_stim*delta_t/60;
colors = colorcube(50);
ntimes = length(ncells{1});
colgr = size(colonies,2);% how many colonies were found

for i = 1:colgr;
    
    ratio = cell(size(colonies(i).cells,2),1);
    tpt = cell(size(colonies(i).cells,2),1);
    
    for k=1:size(colonies(i).cells,2)
        ratio{k} = colonies(i).cells(k).fluorData(:,fldat(1))./colonies(i).cells(k).fluorData(:,fldat(2));
        tpt{k} =  (colonies(i).cells(k).onframes');
        tpt{k} =  (tpt{k}.*delta_t)./60;
    end
    for k=1:size(ratio,1)
        figure(i), plot(tpt{k},ratio{k},'-*','color',colors(k,:));hold on
        legend(['bmp4 added at ' num2str(p) 'hours']);
    end
    ylabel('nuc/cyto raio');
    xlabel('Time, hours');
    ylim([0 2.5])
    hold on
    
    x = (fr_stim*delta_t/60);
    x = ones(1,4).*x;
    y = 0:1:3;
    plot(x,y,'-*r','linewidth',3);
end

end