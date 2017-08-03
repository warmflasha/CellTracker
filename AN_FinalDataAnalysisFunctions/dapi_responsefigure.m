%% figure for the reviewers: Comunity effect in uCOlonies and grad(bmp) in reg culture without normalization to DAPI
close all
% uCOl community effect
 dir = '/Volumes/data2/Anastasiia/13_20160222-PaperFigures_DATA/matlab_Figure1Panels/SF1';
nms = { 'esi017noQd_C(1)_Repeat','esi017noQd_10ng_Repeat'}; % stains: Bra(peaks10) Sox2(peaks8) cdx2(peaks6)
nms2 = {'control','10 ng/ml'};
% nms = { 'esi017noQd_C(1)_Repeat','esi017noQd_1ng_Repeat'}; % stains: Bra(peaks10) Sox2(peaks8) cdx2(peaks6)
% nms2 = {'control','1 ng/ml'};
% nms = { 'esi017noQd_C_finerConc','esi017noQd_10_finerConc'};
% nms2 = {'control','10 ng/ml'};
% dir = '/Volumes/TOSHIBAexte/2017-05-30-DEVELOPMENTrevisionfigures/Bra_inuCOL_results';%'/Volumes/TOSHIBAexte/2017-06-16-ClonaluCol_R/Clonal_R_outfiles';
% nms = {'control_brainucol_R','10bmp_brainucolRArea1'};    %
% nms12 = {'10bmp_clonaluCol_Ra2Cy5Cf5','10bmp_clonaluCol_Ra2Cy5Cf5'};    %
% nms2 = {'control','10'};

index1 = [8] ;
param1 = 'Sox2';
dapimax = 4000; % cell area here
chanmax = 60000; % not used
scaledapi = 0;
flag1 = [];
C = {'c','m','m','c'};
ucol = 8;
  [rawdata,err] =  Intensity_vs_ColSize(nms,nms2,dir,index1,param1,dapimax,chanmax,scaledapi,flag1);% returns a cell array of size(nms,2)
   yl = [5000 7000];
  for k=1:size(nms2,2)    
  figure(k), errorbar(rawdata{k}(1:ucol),err{k}(1:ucol),'-*','color',C{k},'markersize',23,'linewidth',3); hold on;
  ax1 = figure(k);
  ax1.CurrentAxes.FontSize = 28;
  ax1.CurrentAxes.LineWidth = 3;  
  xlim([0.9 ucol+0.1]);
  ylim([0 yl(k)])
  xlabel('Colony size (cells)');
  ylabel(['Mean ',(param1) ' Intensity']);    
  legend(nms2{k},'Location','northwest','orientation','vertical');
  end
  %-------- to reuse
%   dir = '/Volumes/data2/Anastasiia/13_20160222-PaperFigures_DATA/matlab_Figure1Panels/SF1';
% nms = { 'esi017noQd_C(1)_Repeat','esi017noQd_10ng_Repeat'}; % stains: Bra(peaks10) Sox2(peaks8) cdx2(peaks6)
% nms2 = {'control','10 ng/ml'};
% % nms = { 'esi017noQd_C(1)_Repeat','esi017noQd_1ng_Repeat'}; % stains: Bra(peaks10) Sox2(peaks8) cdx2(peaks6)
% % nms2 = {'control','1 ng/ml'};
% % nms = { 'esi017noQd_C_finerConc','esi017noQd_10_finerConc'};
% % nms2 = {'control','10 ng/ml'};
%   
% index1 = [6] ;
% param1 = 'Cdx2';
% dapimax = 5000; % high thresh, so that no removal of DAPI
% chanmax = 60000; % not used
% scaledapi = 0;
% 
dir = '/Volumes/TOSHIBAexte';
C = {'b','r','m','c'};
thresh = [250 300];%cdx2mean 1*ones(1,size(nms2,2))
m = [];
err = [];
ucol = 8;
if scaledapi == 0
for k=1:size(nms2,2)
[dapi(k),ncells] = getmeandapi(nms(k),dir,index1, dapimax);
disp(['cells found' num2str(ncells) ]);
end
dapiscalefactor = dapi/dapi(1);
end
if scaledapi == 0
dapiscalefactor = ones(1,size(nms,2));
end
%[m,err,tot]=bootstrapFrac(dir,nms,set,thresh,Niter,index1,dapimax,ucol)
for k=1:size(nms2,2)
    [m{k},err{k},tot{k}]=bootstrapFrac(dir,nms,k,thresh(k),50,index1,dapiscalefactor(k),ucol);
end

for k=1:size(nms2,2)    
%figure(20),plot(ratios{k},'*-','color',C{k},'MarkerSize',20,'Linewidth',2);hold on %,subplot(1,size(nms2,2),k)
figure(20),errorbar(m{k}(1:ucol),err{k}(1:ucol),'-.','color',C{k},'MarkerSize',20,'Linewidth',3);hold on %,subplot(1,size(nms2,2),k)
ax1 = figure(20);
%ax1 = subplot(1,size(nms2,2),k);
ax1.CurrentAxes.FontSize = 30;
ax1.CurrentAxes.LineWidth = 3;
ylim([0 1]);
xlim([0 ucol+0.1]);
xlabel('Colony size (cells)','FontSize',28,'LineWidth',3);
ylabel(['Fraction ',(param1),'^{+}'],'FontSize',28,'LineWidth',2);
end
%title('Effects of Activin and Lefty')
legend(nms2);
  
  
  %---------
%figure(20),export_fig('/Volumes/TOSHIBAexte/2017-05-30-DEVELOPMENTrevisionfigures/AI_epsPanels/noDAPInorm_CEcdx2.eps','-transparent');%
%10 ngml set
%(k = 2)
% sox 2CE used the control of the 10ng dataset above (k = 1)

%figure(20),export_fig('/Volumes/TOSHIBAexte/2017-05-30-DEVELOPMENTrevisionfigures/AI_epsPanels/noDAPInorm_CEsox2.eps','-transparent');
%%
%----------------

% REGULAR CULTURE RESULTS
clear all
 dir = '/Volumes/data2/Anastasiia/2017-02-09-FIGURES_cellSystems/matfunctions_cellsysnewFigs/outfiles_BmpwoSB_R2';
 nms = {'0bmp0SB','2bmp0SB','6bmp0SB','10bmp0SB','20bmp0SB','30bmp0SB','100bmp0SB'};   % add the 100 ngml dataset
 nms2 = {'0','2','6','10','20','30','100'};% 
 indexvar = [6 8 10];% 
 paramstr = {'Cdx2','Sox2','Bra'};
 titlestr = 'NO SB';
 vect = [0.1 2 6 10 20 30 100];
  vect1 = [1 2 6 10 20 30 100];
 
 C = {'m','g','b'};  
 dapimax =5000; %
 chanmax = 60000;
 %dir = '.';
 usemeandapi =[];
 flag = 1;
 chans = size(paramstr,2);
 newdata = cell(1,size(paramstr,2)); 
 for k=1:chans
 %[newdata{k}] = MeanExpression_noUcol(nms,nms2,dir,[],[],[indexvar(k) 5],param1{k},0,0,dapimax,chanmax);
 [newdata{k}] = GeneralizedMeanAN_noNorm(nms,nms2,dir,[],[],[indexvar(k) 5],paramstr{k},0,0,dapimax,chanmax);
 figure(1),errorbar(vect1',newdata{k}(:,1)./max(newdata{k}(:,1)),newdata{k}(:,2),'-.','color',C{k},'markersize',14,'linewidth',3);hold on
 end
 if flag == 1
 hh = figure(1);box on
 hh.CurrentAxes.LineWidth = 3; hh.CurrentAxes.FontSize = 26; 
 xlabel('BMP4 dose (ng/ml)'); ylabel('Mean Expression (a.u.)');
 hh.CurrentAxes.XTick = vect;
 hh.CurrentAxes.XScale= 'log';
 hh.CurrentAxes.XTickLabel = vect;
 hh.CurrentAxes.XLim = [0 max(vect)];
 hh.CurrentAxes.YLim = [0 4500];
 legend(paramstr,'Orientation','Horizontal'); 
 title(titlestr) ; 
 end
% with SB result
dir = '/Volumes/data2/Anastasiia/2017-02-09-FIGURES_cellSystems/matfunctions_cellsysnewFigs/outfiles_BmpwoSB_R2';
 nms = {'0bmp10SB','2bmp10SB','6bmp10SB','10bmp10SB','20bmp10SB','30bmp10SB','100bmp10SB'};   
 nms2 = {'0','2','6','10','20','30','100'};% 
 indexvar = [6 8 10];% 
 paramstr = {'Cdx2','Sox2','Bra'};
 titlestr = 'With 10 uM SB';
 vect = [0 2 6 10 20 30 100];
  vect1 = [1 2 6 10 20 30 100];
 flag = 1;
C = {'m','g','b'};  
 dapimax =5000; %
 chanmax = 60000;
 %dir = '.';
 usemeandapi =[];
 flag = 1;
 chans = size(paramstr,2);
 newdata = cell(1,size(paramstr,2)); 
 for k=1:chans
 %[newdata{k}] = MeanExpression_noUcol(nms,nms2,dir,[],[],[indexvar(k) 5],param1{k},0,0,dapimax,chanmax);
 [newdata{k}] = GeneralizedMeanAN_noNorm(nms,nms2,dir,[],[],[indexvar(k) 5],paramstr{k},0,0,dapimax,chanmax);
 figure(2),errorbar(vect1',newdata{k}(:,1)./max(newdata{k}(:,1)),newdata{k}(:,2),'-.','color',C{k},'markersize',14,'linewidth',3);hold on
 end
 if flag == 1
 hh = figure(2);box on
 hh.CurrentAxes.LineWidth = 3; hh.CurrentAxes.FontSize = 26; 
 xlabel('BMP4 dose (ng/ml)'); ylabel('Mean Expression (a.u.)');
 hh.CurrentAxes.XTick = vect;
 hh.CurrentAxes.XScale= 'log';
 hh.CurrentAxes.XTickLabel = vect;
 hh.CurrentAxes.XLim = [0 max(vect)];
 hh.CurrentAxes.YLim = [0 4500];
 legend(paramstr,'Orientation','Horizontal'); 
 title(titlestr) ; 
 end
 % normalized to max
 close all
 max1 = max(cat(1,nonorm_withsb{1}(:,1),nonorm_nosb{1}(:,1)));
 max2 = max(cat(1,nonorm_withsb{2}(:,1),nonorm_nosb{2}(:,1)));
 max3 = max(cat(1,nonorm_withsb{3}(:,1),nonorm_nosb{3}(:,1)));
 m = [max1,max2,max3];
 
 for k=1:chans
 figure(1),plot(vect',nonorm_withsb{k}(:,1)./(m(k)*ones(size(nonorm_withsb{k}(:,1)))),'-','color',C{k},'markersize',14,'linewidth',3);hold on
 figure(2),plot(vect',nonorm_nosb{k}(:,1)./(m(k)*ones(size(nonorm_nosb{k}(:,1)))),'-','color',C{k},'markersize',14,'linewidth',3);hold on
 end
 hh = figure(1);box on
 hh.CurrentAxes.LineWidth = 3; hh.CurrentAxes.FontSize = 26; 
 xlabel('BMP4 dose (ng/ml)'); ylabel('Mean Expression (a.u.)');
 hh.CurrentAxes.XTick = vect;
 hh.CurrentAxes.XScale= 'log';
 hh.CurrentAxes.XTickLabel = vect;
 hh.CurrentAxes.XLim = [0 max(vect)];
 hh.CurrentAxes.YLim = [0 1];
 legend(paramstr,'Orientation','Vertical');
 title('With 10 uM SB') ; 

 hh = figure(2);box on
 hh.CurrentAxes.LineWidth = 3; hh.CurrentAxes.FontSize = 26; 
 xlabel('BMP4 dose (ng/ml)'); ylabel('Mean Expression (a.u.)');
 hh.CurrentAxes.XTick = vect;
 hh.CurrentAxes.XScale= 'log';
 hh.CurrentAxes.XTickLabel = vect;
 hh.CurrentAxes.XLim = [0 max(vect)];
 hh.CurrentAxes.YLim = [0 1];
 legend(paramstr,'Orientation','Vertical'); 
 title('NO SB');
 
figure(1),export_fig('/Volumes/TOSHIBAexte/2017-05-30-DEVELOPMENTrevisionfigures/AI_epsPanels/noDAPInorm_regCultureBMPresponseFrac.eps','-transparent');
figure(2),export_fig('/Volumes/TOSHIBAexte/2017-05-30-DEVELOPMENTrevisionfigures/AI_epsPanels/noDAPInorm_regCultureBMPSBresponseFrac.eps','-transparent');
