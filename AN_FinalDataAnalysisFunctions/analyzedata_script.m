%% 
 nms = {'1_LowD_withRI','3_HighD_withRI','2_HighD_noRI'};  
 nms2 = {'Low density, RI','High density, RI','High density, no RI'}; 
 indexvar = [9];
 param1 = {'cytoYAP'};%,'Smad2','Nanog'
 C = {'g','c','m','r'};  
 dapimax =7000;%
 chanmax = 60000;
 dir = '.';
 chans = 1;
 newdata = cell(1,size(param1,2));
 vect = [1:size(nms2,2)];
 for k=1:chans
 [newdata{k}] = GeneralizedMeanAN(nms,nms2,dir,[],[],[indexvar(k) 5],param1{k},0,0,dapimax,chanmax);
 figure(1),errorbar(vect',newdata{k}(:,1),newdata{k}(:,2),'-.','color',C{k},'markersize',14,'linewidth',3);hold on
 
 end
 legend(param1);
 title('Hippo in pluri') ; hh = figure(1);box on
 hh.CurrentAxes.LineWidth = 3; hh.CurrentAxes.FontSize = 18; ylabel('mean/dapi');
 hh.CurrentAxes.XTick = vect;
 hh.CurrentAxes.XTickLabel = nms2;
 hh.CurrentAxes.XLim = [1 vect(end)];
 hh.CurrentAxes.YLim = [0 3];
 %% wnt dataset
 nms = {'control_ucol','30ngmlWNT3a_uCol','100ngmlWNT3a_uCol','300ngmlWNT3a_uCol'};  
 nms2 = {'control','30 nmgl WNT3a','100 nmgl WNT3a','300 nmgl WNT3a'};
 
 indexvar = [8 6 10];
 param1 = {'Sox2','Nanog','Bra'};
 C = {'g','m','r'};  
 dapimax =5000;%now used as the area thresh in colony analysis; dapimax is set to max 60000 within the generalized mean function
 chanmax = 60000;
 dir = '.';
 usemeandapi =[];
 flag = 1;
 chans = 3;
 newdata = cell(1,size(param1,2));
 for k=1:chans
 [newdata{k}] = GeneralizedMeanAN(nms,nms2,dir,[],[],[indexvar(k) 5],param1{k},0,0,dapimax,chanmax);
 figure(2),errorbar([0 30 100 300]',newdata{k}(:,1),newdata{k}(:,2),'-.','color',C{k},'markersize',14,'linewidth',2);hold on
 end
 legend(param1);
 title('WNT doses in uCOlonies') ; hh = figure(2);box on
 hh.CurrentAxes.LineWidth = 3; hh.CurrentAxes.FontSize = 18;xlabel('WNT3a, ng/ml'); ylabel('mean/dapi');
 hh.CurrentAxes.XTick = [0 30 100 300];
 hh.CurrentAxes.XTickLabel = [0 30 100 300];
 hh.CurrentAxes.XLim = [-1 305];
 hh.CurrentAxes.YLim = [0 10];
 
 
 
 %% get the raw data from each channel 
 nms = {'control_ucol','Act_100ngml_uCOl'};    
 dir = '.';
 index = [5 6 8 9 10]; 
 [chandata]= rawdatainchan(nms,dir,index);
  
 %% scatter plots 
 %param = {'dapi','Cdx2','sox2','bra'}; j = 2; xx = 3;
 %everyNtp = 5;
  index = [5 6 8 10];% 
  paramstr = {'dapi','Cdx2','Sox2','Bra'};
  j = 4; xx = 3;
 for k=2%:size(nms2,2)  
 figure(2),scatter(chandata{k}(:,j)./chandata{k}(:,1),chandata{k}(:,xx)./chandata{k}(:,1));hold on
 end
 ylim([0 10]); xlim([0 5]);
 box on;
 h = figure(2); h.CurrentAxes.LineWidth = 3; h.CurrentAxes.FontSize = 18;
 legend(nms2{1:end})
 xlabel(paramstr {j});
 ylabel(paramstr {xx});
 title('scatter');
%% for uColonies scatter plot with colony size colorcode
%  nms = {'control_ucol','Act_100ngml_uCOl'};  
%  nms2 = {'control','100ngml Activin'}; 
param1 = 'Sox2';param2 = 'Bra';
index2 = [8 10];
dapimax = 5000;
toplot = cell(1,size(nms,2));
flag = 0; % generate third column with the col size
flag2 = 1;% do not normalize to DAPI if flag == 0;
for k=1:size(nms,2)
        filename{k} = [dir filesep  nms{k} '.mat'];
        load(filename{k},'peaks','dims','plate1');
        col = plate1.colonies;
        [alldata] = mkVectorsForScatterAN(peaks,col,index2,flag,flag2,dapimax);
        toplot{k} = alldata;
end
for j=1:size(nms,2)
    figure(j),scatter(toplot{j}(:,2),toplot{j}(:,1),[],toplot{j}(:,3),'LineWidth',2); hold on %  
    box on
    ylabel(param1)
    xlabel(param2)
    ylim([0 12]);
    xlim([0 25]); 
    h = figure(j);
    h.Colormap = jet;legend(nms2{j});colorbar
    h.CurrentAxes.FontSize = 18;
    h.CurrentAxes.LineWidth = 3;
end
%% expression vs col sz
nms = {'control_ucol','Act_100ngml_uCOl'};  
nms2 = {'control','100ngml Activin'}; 
% nms = {'control_ucol','30ngmlWNT3a_uCol','100ngmlWNT3a_uCol','300ngmlWNT3a_uCol'};  
% nms2 = {'control','30 nmgl WNT3a','100 nmgl WNT3a','300 nmgl WNT3a'}; 
dir = '.';
index1 = [10 5];
param1 = 'Bra';
chanmax = 60000;
usemeandapi = [];
flag1 = 0;
dapimax = 5000; % areathresh, not use really
 [rawdata,err] =  Intensity_vs_ColSize(nms,nms2,dir,index1,param1,dapimax,chanmax,usemeandapi,flag1);
 for k=1:size(nms2,2)
 figure(k), errorbar(rawdata{k}(1:8,1),err{k}(1:8,1),'-.','linewidth',2); hold on  
 h = figure(k);
 h.CurrentAxes.FontSize = 18;
 h.CurrentAxes.LineWidth = 3;
 xlabel('Colony size, cells');
 ylabel(['mean ' (param1)]);
 h.Colormap = jet;legend(nms2{k});
 ylim([0.5 1.5])
 xlim([0 6.1])
  end
 
 %% hist
%  nms = {'control_ucol','30ngmlWNT3a_uCol','100ngmlWNT3a_uCol','300ngmlWNT3a_uCol','Act_100ngml_uCOl'};  
%  nms2 = {'control','30 nmgl WNT3a','100 nmgl WNT3a','300 nmgl WNT3a','100 gml Activin'};
 nms = {'300ngmlWNT3a_uCol'};  
 nms2 = {'300 ngml WMT3a'};
 dir = '.';
index1 = [6 5];
param1 = 'Nanog';
 ucol = 6;
 flag = 1;
 usemeandapi = [];
 dapimax = 5000;
 [data] =  Hist_vs_ColSize(nms,nms2,dir,index1,param1,dapimax,usemeandapi,flag,ucol);
%% find images with specific colony sizes only
dir = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2017-01-27-WNT3aDosesandActinuCol/300ngmlWNT3a_uCol';
toshow = 5;
chan = [1 3];
dataset = 1;
nms = {'300ngmlWNT3a_uCol'}; 
dtaset = 5;
index1 = [8 5];
nc = 5;
showcol = 5;
thresh = 0.1;
flag = [];flag2 = 2;
[A,B,C] = findcolonyAN(dir,toshow,chan,nms,dataset,index1,thresh,nc,showcol,flag,flag2);

 %% compare bmp4 doses with and without SB
 
 load('meanexpression.mat'); % in this file, the 1,3,5, columns are mean expressions of sox2,cdx2,bra respectively, col 2,4,6,- their errors, col 7 = bmp4dose
 param1 = {'Sox2','Sox2','Cdx2','Cdx2','Bra','Bra'};
 chans = 3; % chanels 
 yy = [3.5 3.5 1 1 0.35 0.35];% upper y-lim
 for k=1:2:(size(noSB,2)-1)
 figure(k), errorbar(noSB(:,end),noSB(:,k),noSB(:,k+1),'--.b','linewidth',2),hold on
 errorbar(withSB(:,end),withSB(:,k),withSB(:,k+1),'-*r','linewidth',2);
 hh = figure(k);
 hh.CurrentAxes.LineWidth = 3; hh.CurrentAxes.FontSize = 18;xlabel('BMP4 concentration, ng/ml'); 
 ylabel([ num2str(param1{k}) '/dapi']);
 hh.CurrentAxes.XTick = [0 1 2.5 4 5.5 7 8.5 10];
 hh.CurrentAxes.XTickLabel = [0 1 2.5 4 5.5 7 8.5 10];
 hh.CurrentAxes.XLim = [-1 11]; 
 hh.CurrentAxes.YLim = [0 yy(k)];
 legend('no SB','with 10 uM SB');
 title('BMP4 doses 1-10 ng/ml');
 end
 
 
 