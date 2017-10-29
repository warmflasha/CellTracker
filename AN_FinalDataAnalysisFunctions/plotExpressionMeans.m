%% plot mean expression 

 close all 
 dir = '/Volumes/TOSHIBAexte/2017-09-21-MiguelAN_trophoblastDiff10bmp10Sb_NanogCdx2p63/Matfiles_4dexperiment_varBMPSBMT';
 nms = {'pluriControl_4dMT','diffControl_2dBmpSb','1d_BmpSb_3d_MT','2d_BmpSb_2d_MT','3d_BmpSb_1d_MT','4d_BmpSb'}; % 
 nms2 = {'Undiff','CDX2posControl','1d diff -> 3d MT','2d diff -> 2d MT','3d diff -> 1d MT','4d diff'};% 
 paramstr = {'DAPI','P63','NANOG','CDX2'}; %
 C = {'r','g','c','m'};
 chans = size(paramstr,2);
 index = [5 8 10 6]; 
 [chandata]= rawdatainchan(nms,dir,index);
 vect = [1 2 3 4 5 6];  
 normto = 1; 
 titlestr = {'4 day experiment, 10 ng/ml BMP4, 10 uM SB'};

[chandata]=plotexpressionmean(dir,nms,nms2,paramstr,vect,normto,index,titlestr);

%% scatter plots
close all

toplot = [1];
sameplot = []; % only if this is 0, then will close all and plot the scatter plots in separate plots
N = 5;
i1 = 2;% to use for scatter plots
i2 = 4;% to use for scatter plots

i3 = 2;% to use as colormap if plotting only one dataset
plotscatter(chandata,nms2,toplot,N,i1,i2,i3,paramstr,normto,sameplot);
xlim([0 2])
ylim([0 3])
%close all

for j=1:size(toplot,2)
    figure(2), histogram(chandata{toplot(j)}(:,i1)./chandata{toplot(j)}(:,normto),'BinWidth',0.06,'Normalization','Probability');hold on;box on%,
    ylim([0 0.5]);
    xlim([0 2]);
end
h = figure(2);
legend(nms2(toplot));
xlabel(paramstr(i1))
ylabel('Frequency')
h.CurrentAxes.FontSize  = 20;
h.CurrentAxes.LineWidth = 3;
 titlestr = {'4 day experiment, 10 ng/ml BMP4, 10 uM SB'};
title(titlestr);

%  [cmin cmax]=caxis;
% caxis([cmin 0.6])
% colorbar
 %% get fractions of x-positive cells
 
 paramstr = {'DAPI','P63','NANOG','CDX2'}; %
 index = [5 8 10 6]; % index2 [1 2 3 4]
 
 colormap = prism; %index = [5 8 10 6]; 
 index2 = 2; % chandata column index
 normto = 1; % chandata column index
 
 thresh = 0.5;% for p63 expression here
 
 %thresh = 0.18; % for CDX2 here
 
 [fractions]=getpositivefrac(nms,nms2,thresh,index2,chandata,normto);
 vect = 1:size(nms2,2);
 for k=1:size(vect,2)
 figure(4),bar(k,fractions(1,k),'Facecolor',colormap(k,:));hold on
 hh = figure(4);box on
 end 
 hh.CurrentAxes.XTickLabel=nms2;
 hh.CurrentAxes.LineWidth = 3; hh.CurrentAxes.FontSize = 20; 
 ylabel(['Fraction ' num2str(paramstr{index2}) ' positive']);
 hh.CurrentAxes.XTick = vect;
 hh.CurrentAxes.XScale= 'linear';
 hh.CurrentAxes.XLim = [0 max(vect)+1];
 hh.CurrentAxes.YLim = [0 0.2];
 hh.CurrentAxes.XTickLabelRotation = 35;
 
  
 
 