%%

% A panel of plots for 1 shape 4 colony

 chn = [6 8 10];
 refac = 1/userParam.umtopxl;
 bd = 1;
 mkdir('/Users/sapnac18/Desktop/shapes1_1/Analysesfunc/colradavg/'); 
 colradavg = '/Users/sapnac18/Desktop/shapes1_1/Analysesfunc/colradavg/';
 shncc = [3:8];
 
%for shn = 1:16
for shn = [1:2 8:16]
    mkdir([colradavg, sprintf('/shn%02d', shn)]);
    for i = 1:numel(colcl{shn});
    %for i = 1
        
      
        m = 1;
         limit = [4 4 8];
         colonyColorPointPlot2(plate1.colonies(colcl{shn}(i)), chn, 5, refac, limit);
            
         hold on;
         for ch = chn
            
             if(ismember(shn, shncc))
               [rA{m}, cb1, dmax] = radavgcc(plate1.colonies(colcl{shn}(i)), ch, 5, 50);
             else
                 [rA{m}, cb1, dmax] = plate1.colonies(colcl{shn}(i)).radialAverage(ch, 5, 50, bd);
             end
            m= m+1;
         end

           rAm = zeros(numel(rA{1}), numel(chn));
        
        for r = 1:numel(rA)
          rAm(:,r) = rA{r};
        end

        n = numel(rA{1});
        
        %
        
        %figure('visible', 'off');
        
        xlim = dmax/cf; % dmax: distance of the furthest point from the center in um
        x = linspace(0, xlim, n);
       
        subplot(2,2,4);
        
        plot(x, rAm);
        
        if(bd == 1)
            xlabel('Distance from edge (um)');
        else
           xlabel('Distance from center (um)');
        end
        
        ylabel('Radial Average (AU)');
        
        tit = sprintf('Colony%d', colcl{shn}(i));
        title(tit);
  
        legend(ll, 'Location', 'best');
        
        file = sprintf('shn%02d/colid%02d', shn, colcl{shn}(i));
        fn = strcat(colradavg,'/', file); 
    
        set(gcf,'PaperPositionMode','auto');
        saveas(gcf, fn, 'pdf');
        
     
      
    end
end

%%
% Scatter Plots
nf = '/Users/sapnac18/Desktop/shapes1_1/Analysesfunc/BravsSox2';
mkdir(nf);

for sh = 1:16
    mkdir ([nf sprintf('/shn%02d', sh)]);
    
    for i = 1:numel(colcl{sh})
        
        figure('visible', 'off');
        plot(plate1.colonies(colcl{sh}(i)).data(:,6), plate1.colonies(colcl{sh}(i)).data(:,10), '.');
        xlabel('Brachury Exp');
        ylabel('Sox2 Exp');
        
        tit = sprintf('Colony%d', colcl{sh}(i));
        title(tit);
        
        file = sprintf('shn%02d/colid%02d', sh, colcl{sh}(i));
        fn = strcat(nf,'/', file); 
    
        set(gcf,'PaperPositionMode','auto');
        saveas(gcf, fn, 'pdf');
        
  
        
    end
end
