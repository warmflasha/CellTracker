%%
clear all;
load('outputn.mat');
colinfo = plate1.colonies.shape;

ncolony = size(plate1.colonies,2);

for i = 1:ncolony
    if(~isempty(plate1.colonies(i).shape))
        colsh(i) = plate1.colonies(i).shape;
    else
        colsh(i) = 0;
    end
end

%%
% classifying colonies based on shape (bar graph: colonies(n))
for i = 1:18
    [c, colcl{i}] = find(colsh == i);
    idcol(i) = numel(colcl{i});
end

%%

% 
% no. of colonies identified for each shape:
%x = [1:16]; 
set(gca,'xTick',x1);
%set(gca,'xTick',[]); 
figure;
bar(1:16, idcol(1:16));
xlim([0 17]);

xlabel('Shape number');
ylabel('No. of colonies identified');
%set(gca,'XTickLabel',a)

%%
%[rA{k}, cb1, dmax] = plate1.colonies(col{i}(j)).radialAverage(ch(k), 5, 50);
% Radial Average for each channel
%legend labels


cf = userParam.umtopxl;
shn = 1; %shape number to be analysed
ch = [6 8 10];  
bd = 1; %expression change from the boundary 

ll = {'Bra', 'Cdx2', 'Sox2'}; %legend label
%%
for i = 1:numel(ch)
    leg{i} = sprintf('ch%2d', ch(i));
end

radavg = '/Users/sapnac18/Desktop/shapes1_1/Analysesfunc/radavg';
mkdir(radavg);


%for shn = [1 2 9 10 11 12 13 14 15 16 18]
%for shn = 3
for shn = [4 5 6 7 8]
    mkdir([radavg, sprintf('/shn%02d', shn)]);
for i = 1: numel(colcl{shn})
    clear rA rAm
    m = 1;
    for chn = ch
      %[rA{m}, cb1, dmax] = plate1.colonies(colcl{shn}(i)).radialAverage(chn, 5, 50, bd);
      [rA{m}, cb1, dmax] = radavgcc(plate1.colonies(colcl{shn}(i)), chn, 5, 50);
      m= m+1;
    end

     rAm = zeros(numel(rA{1}), numel(ch));
        
        for r = 1:numel(rA)
          rAm(:,r) = rA{r};
        end

        n = numel(rA{1});
        
        %
        
        figure('visible', 'off');
        
        xlim = dmax/cf; % dmax: distance of the furthest point from the center in um
        x = linspace(0, xlim, n);
       
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
        fn = strcat(radavg,'/', file); 
    
        set(gcf,'PaperPositionMode','auto');
        saveas(gcf, fn, 'pdf');
        
end
end

%%
direc = '/Users/sapnac18/Desktop/shapes1_1/Analysesfunc/';
% colony color plots

 filen = strcat(direc, 'colclrplotn30');
 mkdir(filen);
   
   %for shn = 1
  
   %for shn = [1 2 9 10 11 12 13 14 15 16 18]
    for shn = [3 4 5 6 7 8];  
      mkdir([direc, sprintf('/colclrplotn30/shn%02d', shn)]);  
      for i = 1: numel(colcl{shn})
            
          mkfl = sprintf('colclrplotn30/shn%02d/col%d', shn, colcl{shn}(i));
          mkfile = strcat(direc, '/', mkfl);
          mkdir(mkfile);

          for k = 1:numel(ch)
              
           rescale_factor = 1/userParam.umtopxl; % pixxels to um conversion
           colonyColorPointPlot1(plate1.colonies(colcl{shn}(i)), [ch(k),5], rescale_factor);
           f = sprintf('_%s',  ll{k});
           fn = strcat(mkfile, '/', f); 
        
           set(gcf,'PaperPositionMode','auto')
           saveas(gcf, fn, 'pdf');
          end
          
        end
    end

close all;

%%
% colony avg.
direc = pwd;
mkfile = strcat(direc, '/', 'colonyavg/');
%mkdir (mkfile);


%%

clear rad1 rA rAm

%for i = 1;
for i = [3:8]
   
    
    for j = 1:numel(ch)
        ra{j} = plate1.radialAverageOverColonies(colcl{i}, ch(j), 5, 50,bd);
    end
    
    rAm = zeros(numel(ra{1}), numel(ch));
  
    
    for k = 1:numel(ch)
        rAm(:,k) = ra{k};
    end
    
    
    for l = 1:numel(colcl{i})
        rad{i}(l) = plate1.colonies(colcl{i}(l)).radius;
    end
    
    radm = mean(rad{i});
    
           
       
            xlim = radm/userParam.umtopxl;
        
        
        x = linspace(0,xlim, numel(ra{1}));
    
      figure('visible', 'off');
    
      plot(x,rAm);
      
      if(bd ==1)
          xlabel('Distance from edge (um)');
      else
          xlabel('Distance from center(um)');
      end
      
      ylabel('Radial Average');
      
      tit = sprintf('Shape%02d', i);
      title(tit);
      
      legend(ll, 'Location', 'best');
       
      set(gcf,'PaperPositionMode','auto');
      
      file = strcat(mkfile, '/', tit);
      saveas(gcf, file, 'pdf');
           
end

   close all;

 
   