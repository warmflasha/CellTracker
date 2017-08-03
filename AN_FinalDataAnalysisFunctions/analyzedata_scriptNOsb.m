%%
files = readMMdirectory('10_BMPnoSBslide');
fullImage=StitchPreviewMM(files,acoords10,'RFP');
%% plot means
close all
 nms = {'Control','1to10ngml_3hr','10to1ngml3hr','1ngmlcontinuous','10ngmlcontinuous','10ngmlto250Noggin_3hr','10ngmlto250Noggin_18hr','10ngmlto250Noggin_28hr'};   
 nms2 = {'Control','1to10@3hr','10to1@3hr','1ngml','10ngml','NOGGIN@3','NOGGIN@18','NOGGIN@28'};% 
 nms = {'control_fixattp3_BG','10ngmlBMP_1hr_BG','10ngmlBMP_6hr_BG','10ngmlBMP_24hrtp3_BG'};   % dapi(5) psmad1(6) smad4(8)
 nms2 = {'control','1hr in 10ngmlBMP','6hr in 10ngmlBMP','24hr in 10ngmlBMP'};% 
 
 indexvar = [5 6 8 10];
 param1 = {'DAPI','CDX2','Sox2','Nanog'};
 colormap = colorcube;
 
 C = {'b','m','g','r'};  
 dapimax =10000;%
 chanmax = 60000;
 dir = '.';
 usemeandapi =[];
 flag = 1;
 chans = 4;
 vect = [1:8];
 newdata = cell(1,size(param1,2));
 for k=1:chans
 [newdata{k}] = GeneralizedMeanAN(nms,nms2,dir,[],[],[indexvar(k) 5],param1{k},0,0,dapimax,chanmax);
   figure(1),plot(vect',newdata{k}(:,1),'-*','color',C{k},'markersize',14,'linewidth',2);hold on
  end
 title('Initial vs ustained BMP4 Signaling') ; hh = figure(1);box on
 hh.CurrentAxes.LineWidth = 3; hh.CurrentAxes.FontSize = 18; ylabel('mean/dapi');
 hh.CurrentAxes.XTick = vect;
 hh.CurrentAxes.XTickLabel =  nms2 ;
 hh.CurrentAxes.XTickLabelRotation = -25;
 hh.CurrentAxes.XLim = [vect(1)-1 vect(end)+1];
 hh.CurrentAxes.YLim = [0 2];
% hh.CurrentAxes.Color = colormap; 
 legend(param1,'Orientation','horizontal');
%  withSB = [];
%  withSB = cat(2,newdata, [0 1 2.5 4 5.5 7 8.5 10]');
 %save('meanexpression','withSB','-append');
 
 %% get the raw data from each channel 
%  nms = {'control_fixattp3','10ngmlBMP_1hr','10ngmlBMP_6hr','10ngmlBMP_24hrtp3'};   % dapi(5) psmad1(6) smad4(8)
%  nms2 = {'control','1hr in 10ngmlBMP','6hr in 10ngmlBMP','24hr in 10ngmlBMP'};% 
 dir = '.';
 nms = {'c_45hrfucciDAPIYFPRFP','10ngmlBMP_45hrfucciDAPIYFPRFP'};   % dapi(5) rfp(6) yfp (8)
 nms2 = {'control','10ngmlBMP'};% 
 %index = [3 5 6 8 9]; 
 index = [3 5 6 8]; 

 chandata = [];
 [chandata]= rawdatainchan(nms,dir,index);
  % eliminate cells that are very bright in dapi
  %chandata2 = cell(size(chandata));
  areathresh = 500;
  for k=1:size(chandata,1)
  [r,~]=find(chandata{k}(:,1)<areathresh);
  chandata{k}(r,:) = [];
    
  end
 %% scatter plots 
 close all
 param = {'Cell Area','dapi','cdx2'}; j =3; xx = 1;s = 2;
 
 normto = 2;
 cyt = 5;
 %everyNtp = 5;
 %q = 1;
 for k=1:size(nms2,2)  
 figure(k),scatter(chandata{k}(:,j)./chandata{k}(:,normto),chandata{k}(:,xx)./chandata{k}(:,normto),[],chandata{k}(:,2));hold on%
 %figure(k),scatter(chandata{k}(:,j),chandata{k}(:,xx),[],chandata{k}(:,s));hold on
 
 h = figure(k); h.CurrentAxes.LineWidth = 3; h.CurrentAxes.FontSize = 18;box on;
 h.Colormap =jet; ylim([0 2]); xlim([0 2]);
 legend(nms2{k})
 xlabel(param{j});
 ylabel(param{xx});
 title(['10 ng/ml BMP4, colordode by ' num2str(param{s})] );
 if k == 1
     title('Control, no BMP4')
 end
 colorbar
 end
 


%% histograms 
% 
 close all
 param = {'Cell Area','dapi','G1','G2'}; j = 4; xx = 3;
 normto = 2;
 binw =35;
 titlestr = {'contrl','10ngml BMP4'};
 %everyNtp = 5;
 %q = 1;
 for k=1:size(nms2,2)  
 %figure(k),scatter(chandata{k}(:,j),chandata{k}(:,xx),[],chandata{k}(:,xx));hold on
 figure(6), histogram(chandata{k}(:,j),'normalization','probability','BinWidth',binw);hold on
 xlabel(param{j});
 ylabel('Freqency'); 
 end
 legend(titlestr);
h = figure(6);
h.CurrentAxes.FontSize = 16;
h.CurrentAxes.LineWidth = 3;
if j==4
h.CurrentAxes.YLim = [0 0.25];
h.CurrentAxes.XLim = [0 900];
end
if j==2
h.CurrentAxes.YLim = [0 0.04];
h.CurrentAxes.XLim = [0 6000];
end
