%% replot with correct dapi normalzation

% nms = {'R2control160','R2Lefty160'};    % ,'Lefty_R','otherMEKi_R'  dapi gfp(sox2) rfp(nanog)
% nms2 = {'control','lefty'};% 

% nms = {'control_ucol','Act_100ngml_uCOl'};    % ,'Lefty_R','otherMEKi_R'  dapi gfp(sox2) rfp(nanog)
% nms2 = {'control','Act100'};% 

 nms = {'0bmp60K','10bmp30K','10bmp60K','10bmp120K'};    % ,'Lefty_R','otherMEKi_R'  dapi gfp(sox2) rfp(nanog)
 nms2 = {'control','30Kcells','60Kcells','120Kcells'};% 
 indexvar = [8 6 10];% 
 param1 = {'Sox2','Cdx2','Bra'};
 C = {'g','m','r'};  
 dapimax =5000; %now used as the area thresh in colony analysis; dapimax is set to max 60000 within the generalized mean function
 chanmax = 60000;
 dir = '.';
 usemeandapi =[];
 flag = 1;
 chans = 3;%size(param1,2);
 newdata = cell(1,size(param1,2));
%  v = [0.1 20 100 500 ];
%  vlbl = [0 20 100 500 ];
%  vstr = {'Cntrl','20Act','100Act','500Lefty'};
 v = [1 2 3 4];
 vlbl = v;
 vstr = nms2;
 for k=1:chans
 %[newdata{k}] = MeanExpression_noUcol(nms,nms2,dir,[],[],[indexvar(k) 5],param1{k},0,0,dapimax,chanmax);
 [newdata{k}] = GeneralizedMeanAN(nms,nms2,dir,[],[],[indexvar(k) 5],param1{k},0,0,dapimax,chanmax);
 figure(10),errorbar(v',newdata{k}(:,1)./max(newdata{k}(:,1)),newdata{k}(:,2),'-.','color',C{k},'markersize',14,'linewidth',3);hold on
 figure(11),errorbar(v',newdata{k}(:,1),newdata{k}(:,2),'-.','color',C{k},'markersize',14,'linewidth',3);hold on

 end
 hh = figure(10);box on
 hh.CurrentAxes.LineWidth = 3; hh.CurrentAxes.FontSize = 16;xlabel('BMP4, ng/ml'); ylabel('mean/dapi');
 hh.CurrentAxes.XTick = vlbl;
 hh.CurrentAxes.XTickLabel = vstr;
 hh.CurrentAxes.XLim = [min(v) max(v)];
 hh.CurrentAxes.YLim = [0 1.1];
 hh.CurrentAxes.XScale = 'linear';
 legend(param1); 
 title('10 ng/ml BMP4, with SB') ;
 hh = figure(11);box on
 hh.CurrentAxes.LineWidth = 3; hh.CurrentAxes.FontSize = 16;xlabel('dose, ng/ml'); ylabel('mean/dapi');
 hh.CurrentAxes.XTick = vlbl;
 hh.CurrentAxes.XTickLabel = vstr;
 hh.CurrentAxes.XLim = [min(v) max(v)];
 hh.CurrentAxes.YLim = [0 2];
 hh.CurrentAxes.XScale = 'linear';
 legend(param1); 
  title('10 ng/ml BMP4, with SB') ; 
 %save('meanexpressionFineBMP','withSBfiner','-append');
 %% cf with / without SB for separate proteins
 %load('meanexpression.mat');
 %load('meanexpressionFineBMP.mat');
 %load('live2Cdx2.mat');
 load('dynCDX2.mat');
 %param1 = {'Cdx2','Cdx2','Cdx2','Cdx2','Cdx2','Cdx2','Cdx2','Cdx2'};
 param1 = {'pSmad1','pSmad1','pSmad1','pSmad1','pSmad1','pSmad1','pSmad1','pSmad1'};
 C = {'r','r','g','g','b','b','m','m'};
 yl = [1.5 1.5 1 1 0.3 0.3];
 dat1 = cat(2,onedyn{1},threedyn{1},tendyn{1},thirtydyn{1});
 dat2 = cat(2,onedyn{2},threedyn{2},tendyn{2},thirtydyn{2});
 v1 = [1 24 34 46];
 for k=1:2:(size(dat1,2))
     figure(1), plot(v1',dat2(:,k),'-*','color',C{k},'markersize',10,'linewidth',2);hold on; box on
     %errorbar(v1',noSBlive2{1}(:,k),noSBlive2{1}(:,k+1),'-.b','markersize',10,'linewidth',2);hold on;box on
     hh = figure(1);
 hh.CurrentAxes.LineWidth = 3; hh.CurrentAxes.FontSize = 16;xlabel('time, hours'); ylabel('mean/dapi');
 hh.CurrentAxes.XTick = v1';
 hh.CurrentAxes.XTickLabel = v1';
 hh.CurrentAxes.XLim = [-0.5 max(v1)+1];
 %hh.CurrentAxes.YLim = [0 yl(k)];
 title(param1{k});
 end
 legend('1','3','10','30')
 
 
 %%
 nms = {'C_noBMPnoSBslide','05_BMPnoSBslide','2_BMPnoSBslide','10_BMPnoSBslide','25_BMPnoSBslide','100_BMPnoSBslide'};   
 nms2 = {'C','0.5','2','10','25','100'};% 
 
 nms = {'C_withSBplate','05_bmp_withSB','2_bmp_withSB','10_bmp_withSB','25_bmp_withSB','100_bmp_withSB'};   
 nms2 = {'C','0.5','2','10','25','100'};%
 
 nms = {'ZeroBMPnoSB','1BMPnoSB','2.5BMPnoSB','4BMPnoSB','5.5BMPnoSB','7BMPnoSB','8.5BMPnoSB','10BMPnoSB'};   
 nms2 = {'C','1bmp','2.5bmp','4 bmp','5.5bmp','7bmp','8.5bmp','10bmp'};%
 
 nms = {'ZeroBMPnoSB','1BMPnoSB','2.5BMPnoSB','5.5BMPnoSB','7BMPnoSB','8.5BMPnoSB','10BMPnoSB'};   
 nms2 = {'C','1bmp','2.5bmp','5.5bmp','7bmp','8.5bmp','10bmp'};%
 
 nms = {'ZeroBMPwithSB','1BMPwithSB','2.5BMPwithSB','4BMPwithSB','5.5BMPwithSB','7BMPwithSB','8.5BMPwithSB','10BMPwithSB'};   
 nms2 = {'C','1bmp','2.5bmp','4bmp','5.5bmp','7bmp','8.5bmp','10bmp'};%
 
 nms = {'C_noBMPwithSB_live2','1ngmlBMPwithSB_live2','3ngmlBMPwithSB_live2','10ngmlBMPwithSB_live2'};   
 nms2 = {'0 bmp','1 bmp','3bmp','10 bmp'};% 
 
 nms = {'control_t0','1ngmlBMPwSB_t24hr','1ngmlBMPwSB_t34hr','1ngmlBMPwSB_t46hr'};   
 nms2 = {'no BMP,tp0','1 bmp4tp24','1 bmp4tp34','1 bmp4tp46'};% 
 %---------------
 nms = {'esi017noQd_C_finerConc','esi017noQd_01_finerConc','esi017noQd_03_finerConc','esi017noQd_1_finerConc','esi017noQd_3_finerConc','esi017noQd_10_finerConc','esi017noQd_30_finerConc'};   
 nms2 = {'C','0.1','0.3','1','3','10','30'};% 
 
 %-------fixed after  live:
 nms = {'C_S4cellsdapiCdx2_feb3img','03bmpwSB_S4cellsdapiCdx2_feb3img','07bmpwSB_S4cellsdapiCdx2_feb3img','1bmpwSB_S4cellsdapiCdx2_feb3img','16bmpwSB_S4cellsdapiCdx2_feb3img'};   
 nms2 = {'C','0.3','0.7','1','16'};% 
 %% bar plots
 nms = {'2_bmp_withSB','2_bmp_withSBnoRI','100_bmp_withSB','100_bmp_withSBnoRI'};   
 nms2 = {'2','2 without RI','100','100 without RI'};% 
 indexvar = [8 6 10];
 param1 = {'Sox2','Cdx2','Bra'};
 C = {'g','m','r'};
 barwidth = [0.8 0.6 0.4];
 dapimax =5000;%now used as the area thresh in colony analysis; dapimax is set to max 60000 within the generalized mean function
 chanmax = 60000;
 dir = '.';
 usemeandapi =[];
 flag = 1;
 chans = 3;
 newdata = cell(1,size(param1,2));
 v = [1 2 3 4];
 for k=1:chans
  [newdata{k}] = MeanExpression_noUcol(nms,nms2,dir,[],[],[indexvar(k) 5],param1{k},0,0,dapimax,chanmax);
  figure(1),bar(newdata{k}(:,1),barwidth(k),'FaceColor',C{k});hold on
 end
 hh = figure(1);box on
 hh.CurrentAxes.LineWidth = 3; hh.CurrentAxes.FontSize = 16; ylabel('mean/dapi');
 hh.CurrentAxes.XTick = v;
 hh.CurrentAxes.XTickLabel = {'2 bmp,+RI ',' 2 bmp,-RI','  100 bmp,+RI ','   100 bmp,-RI'};
 hh.CurrentAxes.XLim = [0 max(v)+1];
 hh.CurrentAxes.YLim = [0 2.5];
 legend(param1); 
 title('with 10 uM SB') ;
 
 
  %% get the raw data from each channel no SB
 nms = {'esi017noQd_C_finerConc','esi017noQd_01_finerConc','esi017noQd_03_finerConc','esi017noQd_1_finerConc','esi017noQd_3_finerConc','esi017noQd_10_finerConc','esi017noQd_30_finerConc'};   
 nms2 = {'C','0.1','0.3','1','3','10','30'};% 
 dir = '.';
 index = [5 6 8 10]; 
 [chandata]= rawdatainchan(nms,dir,index);
 
 %% scatter plots 
 param = {'dapi','Nanog','Sox2','Bra'}; j = 2; j2 = 3; xx = 3;
 sox2thresh = 0.7;
 cdx2thresh = 0.5;
 brathresh =1;%0.17
 soxfr = zeros(1,6); 
 cdx2fr = zeros(1,6); 
 brafr = zeros(1,6); 
 everyN = 3;
 scaledapi = 1;
 
 for k=1:size(nms2,2)
dapi(k)= mean(chandata{k}(:,1));
disp(['cells found' num2str(size(chandata{k}(:,1))) ]);
 end
 if scaledapi == 1
dapiscalefactor = dapi/dapi(1);
 end
 if scaledapi == 0
dapiscalefactor = ones(1,size(nms2,2));
 end
 for k=1:size(nms,2)
 figure(1),scatter((chandata{k}(:,j)./(chandata{k}(:,1))./dapiscalefactor(k)),chandata{k}(:,xx)./(chandata{k}(:,1))./dapiscalefactor(k));hold on 
 figure(size(nms,2)+1), plot(k,mean(chandata{k}(:,1).*dapiscalefactor(k)),'*m','Markersize',18,'Linewidth',3); hold on
 ylim([0 10]); xlim([0 10]);
 box on;
 h = figure(1); h.CurrentAxes.LineWidth = 3; h.CurrentAxes.FontSize = 18; h.Colormap = parula;
 figure(1),legend(nms2)
 xlabel(param{j});
 ylabel(param{xx});
 if scaledapi == 1
     title('scaledapi')
 end
 if scaledapi == 0
     title('do not scale dapi')
 end
 h = figure(size(nms,2)+1); h.CurrentAxes.LineWidth = 3; h.CurrentAxes.FontSize = 18; h.Colormap = parula;
 xlabel('Condition');
 ylabel('dapi');
 h.CurrentAxes.YLim = [0 3000];
 h.CurrentAxes.XLim = [1 size(nms,2)];
 h.CurrentAxes.XTick = (1:size(nms2,2));
 h.CurrentAxes.XTickLabel = nms2;
 if scaledapi == 1
     title('scaledapi')
 end
 if scaledapi == 0
     title('do not scale dapi')
 end
 end
% legend(nms2);
 %% histograms
 
 param = {'dapi','Cdx2'}; j = 2;j2 = 3; xx = 4;
 
 for k=1:(size(nms,2))
 figure(3),histogram((chandata{k}(:,j)./chandata{k}(:,1)),'BinWidth',0.1,'normalization','probability');hold on 
 box on;
 h = figure(3); h.CurrentAxes.LineWidth = 3; h.CurrentAxes.FontSize = 18; h.Colormap = colorcube;
 xlabel(param{j});
 ylabel('probability');
 ylim([0 0.3]); xlim([0 4]);
 end
  legend(nms2)%{1:3}
  title('with SB, fixed after live cell')
  
  %% fractions of positive cells
 param = {'dapi','Cdx2','Sox2','Bra'}; j = 2; j2 = 3; xx = 4;
 cdx2thresh = 1;
 brathresh = 0.8;
 
   v = [0 1 2.5 4 5.5 7 8.5 10];


 soxfr = zeros(1,size(nms2,2)); 
 cdx2fr = zeros(1,size(nms2,2)); 
 brafr = zeros(1,size(nms2,2)); 
 exclusivebrafr = zeros(1,size(nms2,2)); 
 for k=1:size(nms,2)
 d = chandata{k}(:,xx)./chandata{k}(:,1);
  alldat = size(d,1);
 [r,~] = find(d>brathresh);    % express bra above  thresh
 [r1,~] = find(d>cdx2thresh);  % express cdx2 above thresh
 coex = intersect(r,r1);       % cells that coexpress cdx2 and bra
             
 onlybra = size((r),1)-size(coex,1); 
 exclusivebrafr(1,k) = onlybra/alldat;  
 brafr(1,k) = size(r,1)/alldat;  
 end
  figure(1),plot(v,brafr,'-*m','linewidth',3) ;hold on%./max(brafr)
  figure(1),plot(v',exclusivebrafr,'-*b','linewidth',3) ; % ./max(exclusivebrafr)
  hh = figure(1);box on
 hh.CurrentAxes.LineWidth = 3; hh.CurrentAxes.FontSize = 16;xlabel('BMP4 dose, ng/ml'); ylabel('Fraction above thresh');
 hh.CurrentAxes.XTick = v;
 hh.CurrentAxes.XTickLabel = v;
 %hh.CurrentAxes.XLim = [0 max(v)];
 hh.CurrentAxes.YLim = [0 max(brafr)];
% hh.CurrentAxes.XScale = 'log';
 legend('excluseveBra','coexpresseswithCdx2'); 
 title('withSB ex3, no waiting') ; 
  
  