%% no SB
 nms = {'C_noBMPnoSB_live2','1ngmlBMPnoSB_live2','3ngmlBMPnoSB_live2','10ngmlBMPnoSB_live2'};   
 nms2 = {'0 bmp','1 bmp','3bmp','10bmp'};% 
 index1 = [6 5]; % dapi cy5 gfp
 param1 = 'Cdx2'; 
 dapimax =5000;%now used as the area thresh in colony analysis; dapimax is set to max 60000 within the generalized mean function
 chanmax = 60000;
 dir = '.';
 usemeandapi =[];
 flag = 1;
 [newdata] = GeneralizedMeanAN(nms,nms2,dir,[],[],index1,param1,0,flag,dapimax,chanmax);
 title('no SB,livecell1') ; hh = figure(1);
 hh.CurrentAxes.LineWidth = 3; hh.CurrentAxes.FontSize = 18;xlabel('BMP4 concentration, ng/ml'); 
 
 hh.CurrentAxes.XTickLabel = [0 1 3];
 %% with SB 
 nms = {'C_noBMPwithSB_live2','1ngmlBMPwithSB_live2','3ngmlBMPwithSB_live2','10ngmlBMPwithSB_live2'};   
 nms2 = {'0 bmp','1 bmp','3bmp','10 bmp'};% 
 index1 = [6 5]; % dapi cy5 gfp
 param1 = 'Cdx2'; 
 dapimax =5000;%now used as the area thresh in colony analysis; dapimax is set to max 60000 within the generalized mean function
 chanmax = 60000;
 dir = '.';
 usemeandapi =[];
 flag = 1;
 [newdata] = GeneralizedMeanAN(nms,nms2,dir,[],[],index1,param1,0,flag,dapimax,chanmax);
 title('with 10 uM SB,livecell1') ; hh = figure(1);
 hh.CurrentAxes.LineWidth = 3; hh.CurrentAxes.FontSize = 18;xlabel('BMP4 concentration, ng/ml'); 
 
 hh.CurrentAxes.XTickLabel = [0 1 3 10];
  title('livecell2,27hrs total')
 %% get the raw data from each channel no SB
 nms = {'C_noBMPnoSB_live2','1ngmlBMPnoSB_live2','3ngmlBMPnoSB_live2','10ngmlBMPnoSB_live2'};   
 nms2 = {'0 bmp','1 bmp','3bmp','10bmp'};% 
 dir = '.';
 index = [5 6 8 9]; 
 [chandata]= rawdatainchan(nms,dir,index);
 
   %% get the raw data from each channel WIth SB
 nms = {'C_noBMPwithSB_live2','1ngmlBMPwithSB_live2','3ngmlBMPwithSB_live2','10ngmlBMPwithSB_live2'};   
 nms2 = {'0 bmp','1 bmp','3bmp','10 bmp'};% 
 dir = '.';
 index = [5 6 8 9]; 
 [chandata]= rawdatainchan(nms,dir,index);
 %% scatter plots 
%  param = {'dapi','cdx2','smad4 nuc','smad4 cyto'}; j = 3;j2 = 4; xx = 2;
%  sox2thresh = 0.7;
%  cdx2thresh = 0.7;
%  brathresh =1;%0.17
%  soxfr = zeros(1,6); 
%  cdx2fr = zeros(1,6); 
%  brafr = zeros(1,6); 
%  
%  for k=1:4  
%  figure(k),scatter((chandata{k}(:,j)./chandata{k}(:,j2)),chandata{k}(:,xx)./chandata{k}(:,1),[],chandata{k}(:,j)./chandata{k}(:,j2));hold on
%  %end
%  ylim([0 3.5]); xlim([0 3.5]);
%  box on;
%  h = figure(k); h.CurrentAxes.LineWidth = 3; h.CurrentAxes.FontSize = 18;
%  legend(nms2{k})
%  xlabel(param{j});
%  ylabel(param{xx});
%  title('with SB ');
%  end
 %% scatter same fig

 param = {'dapi','cdx2:dapi','smad4 nuc:cyto','smad4 cyto'}; j = 3;j2 = 4; xx = 2;
 sox2thresh = 0.7;
 cdx2thresh = 0.7;
 brathresh =1;%0.17
 soxfr = zeros(1,6); 
 cdx2fr = zeros(1,6); 
 brafr = zeros(1,6); 
 everyNtp = 5;
 for k=1:size(nms2,2)
 figure(3),scatter((chandata{k}(1:everyNtp:end,j)./chandata{k}(1:everyNtp:end,j2)),chandata{k}(1:everyNtp:end,xx)./chandata{k}(1:everyNtp:end,1));hold on;
 
 end
 ylim([0 3.5]); xlim([0.6 2]);
 box on;
 h = figure(3); h.CurrentAxes.LineWidth = 3; h.CurrentAxes.FontSize = 18;
 legend(nms2{1:end})
 xlabel(param{j});
 ylabel(param{xx});
 title('with SB, liveimg2 ');
 
 
 
 
 