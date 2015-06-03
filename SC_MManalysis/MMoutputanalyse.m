function MMoutputanalyse (dir, outfile, coldatacolr, radavg, colavg, colcolr)
%%%%%

% dir: Directory that has the output file. If the current directory
% contains the output file, then pass '.' as an argument. 
% outfile : Output file. 

%%% For the other four arguments, coldatacolr, radavg, colavg, colcolr, pass 'y' or 'Y'
% in the function call if you wish to perform either of those operations. 
% 
% coldatacolr : cells plotted as colored points in the circular colony. 
% radavg : radial average for all channels in all colonies identified. 
% colavg : radial average across all colonies for a given radius of micropattern. 
% colcolr : colony color point plots for each of the different channels for
% all colonies identified. 

%%% The ouput plots are saved as pdf files in a new folder created in the
%%% current directory. 

%%%%%


% load output file

if (dir == '.')
   dir = pwd;
end


    file = strcat(dir, '/', outfile);
    load(file);

% select the colonies of required diameter
col{1} = plate1.inds200; 
col{2} = plate1.inds500;
col{3} = plate1.inds800;
col{4} = plate1.inds1000;

crad = [200,500,800,1000];
ch = [6,8,10];

%
conv = userParam.umtopxl;

%legend labels
for i = 1:numel(ch)
    leg{i} = sprintf('ch%2d', ch(i));
end
%%
%radial Average for all colonies identified. 

if(radavg == 'y'|| radavg =='Y')

   
for i = 1:numel(col)
    
    mkfl = sprintf('radialavg/dia_%d/', crad(i));
    
    
     mkfile = strcat(dir, '/', mkfl); % A new folder for every colony index
     mkdir(mkfile);
    
  
    for j = 1:numel(col{i})
        
        for k = 1:numel(ch)
           [rA{k}, cb1, dmax] = plate1.colonies(col{i}(j)).radialAverage(ch(k), 5, 50);
        end
        
        rAm = zeros(numel(rA{1}), numel(ch));
        
        for r = 1:numel(rA)
          rAm(:,r) = rA{r};
        end
        
      %%  
        a = plate1.colonies(col{i}(j));
        rad = a.radius;
            
        n = numel(rA{1});
        
        %
        
        xlim = dmax/conv; % dmax: distance of the furthest point from the center 
        
        
        x = linspace(0, xlim, n);

        figure('visible', 'off');
        
        plot(x, rAm);
        
        xlabel('Distance from center (um)');
        ylabel('Radial Average');
        
        tit = sprintf('Colony%d', col{i}(j));
        title(tit);
        
        
        
        legend(leg, 'Location', 'best');
%          
 
    f = sprintf('colid%02d', col{i}(j));
    fn = strcat(mkfile,'/', f); 
    
    set(gcf,'PaperPositionMode','auto');
    saveas(gcf, fn, 'pdf');
        
    end
    
end       

close all;

end


%%
%Colony Radial Average
if (colavg == 'y' || colavg == 'Y')
mkfile = strcat(dir, '/', 'colonyavg/');
mkdir (mkfile);


%%

clear rad1 rA rAm


for i = 1: numel(crad)
   
    
    for j = 1:numel(ch)
        ra{j} = plate1.radialAverageOverColonies(col{i}, ch(j), 5, 50,0);
    end
    
    rAm = zeros(numel(ra{1}), numel(ch));
  
    
    for k = 1:numel(ch)
        rAm(:,k) = ra{k};
    end
    
    
    for l = 1:numel(col{i})
        rad{i}(l) = plate1.colonies(col{i}(l)).radius;
    end
    
    radm = mean(rad{i});
    
           
       
            xlim = radm*0.66;
        
        
        x = linspace(0,xlim, numel(ra{1}));
    
      figure('visible', 'off');
    
      plot(x,rAm);
      xlabel('Distance from center (um)');
      ylabel('Radial Average');
      
      tit = sprintf('ColonyDiameter%d', crad(i));
      title(tit);
      
      legend(leg, 'Location', 'best');
       
      set(gcf,'PaperPositionMode','auto');
      
      file = strcat(mkfile, '/', tit);
      saveas(gcf, file, 'pdf');
           
end

   close all;
end
 
%%
%Colony Color Point Plots of individual colonies and markers. 

if (colcolr == 'y' || colcolr == 'Y')
    
  
    for i= 1:numel(col)
        for j = 1: numel(col{i})
            
          mkfl = sprintf('colclrplot/rad%d/col%d', crad(i), col{i}(j));
          mkfile = strcat(dir, '/', mkfl);
          mkdir(mkfile);

          for k = 1:numel(ch)
              
           rescale_factor = 1/conv; % pixxels to um conversion
           colonyColorPointPlot1(plate1.colonies(col{i}(j)), [ch(k),5], rescale_factor);
           f = sprintf('ch%d',  ch(k));
           fn = strcat(mkfile, '/', f); 
        
           set(gcf,'PaperPositionMode','auto')
           saveas(gcf, fn, 'pdf');
          end
          
        end
    end

close all;
end     
   
%%
%PlotColonyColorPoint (Just all datapoints in a given colony)
if (coldatacolr == 'y' || coldatacolr == 'Y')
   
   
    for i = 1:numel(col)
         
        
     mkfl = sprintf('coldatacolr/dia_%d/', crad(i));
     mkfile = strcat(dir, '/', mkfl); 
     mkdir(mkfile);

        for j = 1:numel(col{i})
         
          figure('visible', 'off'); 
          plate1.colonies(col{i}(j)).plotColonyColorPoints();
         
         f = sprintf('im%02d', col{i}(j));
         fn = strcat(mkfile, '/', f); 
        
         set(gcf,'PaperPositionMode','auto')
         saveas(gcf, fn, 'pdf');
     
        end
     end

close all;
end
