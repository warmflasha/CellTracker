    %%
% determine the background images(for all chnnels) for the dataset to run
ff=readMMdirectory('pluriControl_4dMT');   % dapi, cy5, gfp
dims = [ max(ff.pos_x)+1 max(ff.pos_y)+1];
wavenames=ff.chan;

maxims= dims(1)*dims(2);

%generate background image for each channel

    for ii=1:length(wavenames) % get the background image for al channels  
        [minI, meanI]=mkBackgroundImageMM(ff,ii,min(500,maxims));
        bIms{ii}=uint16(2^16*minI);
        nIms{ii}=ones(size(bIms{ii}));
%         normIm=(meanI-minI);%%%%%%%%comment the next 3 lines (15-18) if running microcolonies
%         normIm=normIm.^-1;
%         normIm=normIm/min(min(normIm));
%         nIms{ii}=normIm;
    end
    %% if background images in each channel were taken while imaging ( just an area on the plate without cells, taken in each channel with the same settings as imaging)
ff=readMMdirectory('C_clonaluCol_R_area1');   %    {'CFP'  'CY5'  'RFP'}
dims = [ max(ff.pos_x)+1 max(ff.pos_y)+1];
wavenames=ff.chan;
for ii=1:length(wavenames)
bIms{ii} = imread('control_bIms.tif','Index',ii);
nIms{ii}=ones(size(bIms{ii}));
end

%%
% script to optimize the segmentation parameters. Can look at a chosen image
% and adjust the parameters. N is a linear index, image number
% need to be one directory up from the actual images folder ( since using
% the readMM2irectory function here)
% 
%for k=8:5:25
close all
 N =20;%  003008 cdx2neg cells
flag = 1;% plot the resulting segmentation on images
% dapi = gb = ~ 1000; cy5: bg=~ 1000; gfp: bg~ 2300;% high bmp dose, pS1-S4
% bIms{1} = uint16(1000*ones(size(bIms{1})));
% bIms{2} = uint16(2300*ones(size(bIms{2})));
% bIms{3} = uint16(1000*ones(size(bIms{3})));
[data1,mask1,toshow1]=ANrunOneMM('1d_BmpSb_3d_MT',N,bIms,nIms,'setUserParamAN20X','DAPI',flag);%setUserParamAN20X  setUserParamAN20X_uCOL
imcontrast
%% sorted segmentation
  close all
  N =2%  
  flag = 1;
  ff = readMMdirectory('/Volumes/TOSHIBAexte/2017-08-02-predifferentiatedcellsControls_sorting/30to70mix_cfpcells2daysbmpSB_2daysinMtesr');%CellsSortedonUpattern_60to40(idx = [6 8 10]cfp sox2 bra); 80to20sortedpattern_cfpBraSox2
   %[nuc1,fmask,statsout]= makeMaskswithmultiplechanelsMM(ff,N,bIms,nIms,'setUserParamAN20X',flag);
   chanmerge=[1 3];
   areamin=80;
   areamax=2500;
 [nuc1,fmask,statsout]=  makeMaskswith2chans_nooverlap(ff,N,bIms,nIms,'setUserParamAN20X',flag,chanmerge,areamin,areamax);
  %[alldata1,fmask,statsout]=
  %makeMaskswithmultiplechanelsMM % not general enough, do not use
  %
  %%
toplot =cat(1,statsout.Centroid);
A =regionprops(logical(fmask),'Area','Centroid');
  A1 =cat(1,A.Area);
  toplot =cat(1,A.Centroid);
figure(2), imshow(fmask,[]), hold on
plot(toplot(:,1),toplot(:,2),'*g');hold on
text(toplot(:,1)+10,toplot(:,2)+10,num2str(A1),'Color','r')

%%
clear all
% PLOT STUFF
   close all
 nms = {'C_clonaluCol_Ra1Cy5Cf5','10bmp_clonaluCol_Ra2Cy5Cf5'};  
 nms2 = {'C','10bmp'};
% 
dapimax =2000;%
chanmax = 60000;
dir = '.';
scaledapi =[1 1];
flag1 = 1;
thresh =[2.5 2.5]; 
[mediaonly,~,~,~,~]= plotallanalysisAN(thresh,nms,nms2,dir,[],[],[5],[6 8],'CY5','Dapi',0,1,dapimax,chanmax,scaledapi,flag1);  
h = figure(1);
h.Children.FontSize = 14;

%% get scatter plots

close all 
dir = '/Volumes/TOSHIBAexte/2017-07-18-testifcellsrevertfromCDX2pos/prediffCFPcells_CFPRFPnanogCY5cdx2';
 nms = {'prediffCFPcells_CFPRFPnanogCY5cdx2'};   
 %nms2 = {'10ng/ml BMP4 10 uM SB'};% 
 paramstr = {'CFP','Nanog','Cdx2'};
 chans = size(paramstr,2);
 index = [5 8 6]; 
 [chandata]= rawdatainchan(nms,dir,index);
figure(1), scatter(chandata{1}(1:3:end,2),chandata{1}(1:3:end,3),[],'m');hold on;
figure(2), scatter(chandata{1}(1:3:end,2)./chandata{1}(1:3:end,1),chandata{1}(1:3:end,3)./chandata{1}(1:3:end,1),[],'b');hold on;
box on
h = figure(1);box on
title('diffCFP+ cells moved to Mtesr for 42 hrs')
h.CurrentAxes.LineWidth = 3;
h.CurrentAxes.FontSize = 20;
ylabel('CDX2 intensity (a.u.)');
xlabel('Nanog intensity (a.u.)');
h.Colormap = jet;
box on
xlim([0 3800]);
ylim([0 900]);
h = figure(2);box on
title('diffCFP+ cells moved to Mtesr for 42 hrs')
h.CurrentAxes.LineWidth = 3;
h.CurrentAxes.FontSize = 20;
ylabel('CDX2 intensity (a.u.), norm to CFP');
xlabel('Nanog intensity (a.u.), norm to CFP');
xlim([0 3.8]);
ylim([0 1]);


%%
%plot mean values of expression specifically for the given colony size 'esi017noQd_01_finerConc'
nms = {'esi017noQd_C_finerConc','esi017noQd_03_finerConc','esi017noQd_1_finerConc','esi017noQd_3_finerConc','esi017noQd_10_finerConc','esi017noQd_30_finerConc'};% ,'C_42hrinmedia'
nms2 = {'c','0.3','1','3','10','30'};
% nms = {'PluriNtwInh_Control(R)','PluriNtwInh_FGFi(R)'};
% nms2 = {'Control','MEKi'};%,'42 hr in media'
dapimax = 4000;%4000

dir = '.';
index1 = [6 5];param1 ='Cdx2';N = 8;
for j=N
[findat] = MeanDecomposedbyColAN(nms,nms2,dir,index1,param1,dapimax,j);
hold on; figure(7),
 hold on
end
title('Mean expression for colonies of size N');
legend([num2str(N)]);
%legend('2','4','6','8');
ylim([0 6])
%%
%plot the mean fraction of cells expressing above thresh , for each colony
%size; 
% to answer the question whether the colonies become more speckled,
%when CE goes awau or not, if yes, then this mean fraction should grow in
%larger colonies after CE is not there (via MEKi)
 nms = {'PluriNtwInh_Control(R)','PluriNtwInh_FGFi(R)'};     % PluriNtwInh_FGFi(R)  PluriNtwInh_Control(R)
 nms2 = {'control','MEKi'}; % ,'MEKi'                  %
 nms3 = {'control','MEKi','theor'}; % ,'MEKi' 
 
 index = [8];param1 = 'Sox2';

 thresh =1.2;% 1.2
dapimax =60000;%10000
flag = 0;
N = 2;
dir = '.';
clear theor
prob = 0.8;   % from this experiment(mean fractions)
    for k=1:size(nms,2)
        [binN, totalcoloniesN,vect] = expressiondistincol(dir,nms,thresh,nms2,param1,index,N,flag);
        [np]= PartitionFn_noInteraction(N,prob); % get the probability for no interactions model
        theor{k} = np;
        
        figure(12), plot(vect',binN{k},'-*','markersize',18,'linewidth',3);hold on
        legend(nms2{k}); 
        figure(12), plot(vect',theor{k},'-k','markersize',18,'linewidth',3);hold on
    end
        xlim([0 N+1]);
        xlabel('Number of positive cells in the colony','fontsize',15);
        ylabel(['Fraction of ' [num2str(N)] '-cell colonies with x ',(param1) ' positive cells'],'fontsize',15);
        ylim([0 1]);
        title(['colonies of size  ' num2str(N) ]);
        legend(nms2)

    
%%
% obtain the scatter plots directly from the peaks of all the datasets in
% nms, 
%  nms = {'Control_pAktdyn','FGFRi_1hr_pAktdyn','FGFRi_6hr_pAktdyn','FGFRi_24hr_pAktdyn','FGFRi_30hr_pAktdyn','FGFRi_42hr_pAktdyn'}; 
%  nms2 = {'control','1 hr','6 hr','24 hr', '30 hr', '42 hr'}; %  nanog(555) peaks{}(:,8), pERK(488) peaks{}(:,6)
   
nms = {'control6hrperknanog','meki_6hr_perknanog'};% ,'C_42hrinmedia'
 nms2 = {'C 6hr','MEKi 6hr'};%,'42 hr in media'%dapi,gfp(8),cy5(6)
 % nanog(RFP), pERK(GFP)
param1 = 'pERK';
param2 = 'Nanog';
index2 = [6 8];
flag3 = 1; % 0 if don't want to normalize to dapi, 1  or empty = do normalize to dapi
% scatter plot of index2(1) vs index2(2) for the dataset nms2{1}
[b,c] = GeneralizedScatterAN(nms,nms2,dir,[],[],index2,param2,param1,0,flag3);

%b{k} : k runs from 1:size(nms2,2)
% cell array b contains all the normalized values of intex2(1) 
% cell array c contains all the normalized values of index1(2) 
for k=1:size(nms2,2)
figure(10), subplot(1,size(nms2,2),k), scatter(b{k},c{k},[],c{k});
xlim([0 10]);
ylim([0 10]);
%colorbar
xlabel(['Normalized  ' num2str(param1)]);
ylabel(['Normalized  ' num2str(param2)]);
box on
legend(nms2{k});
end


%%
% plot the scatter plots colorcoded
%  nms = {'FGFinCE_Control','FGFinCE_FGFhigh','FGFinCE_FGFi'}; % dapi gfp cy5 
%  nms2 = {'control','high','PD98059'};%,PD98059
 % nanog(RFP), pERK(GFP)
param1 = 'Nanog';
param2 = 'Bra';
index2 = [6 10];
%index2 = [6 8];
dapimax = 5000;
toplot = cell(1,size(nms,2));
flag = 0;% generate third column with the col size
flag2 = 1;% do not normalize to DAPI if flag == 0;
for k=1:size(nms,2)
        filename{k} = [dir filesep  nms{k} '.mat'];
        load(filename{k},'peaks','dims','plate1');
        col = plate1.colonies;
[alldata] = mkVectorsForScatterAN(peaks,col,index2,flag,flag2,dapimax);
 toplot{k} = alldata;
end
for j=1:size(nms,2)
    figure(8+j),scatter(toplot{j}(:,2),toplot{j}(:,1),[],toplot{j}(:,3),'LineWidth',2);legend(nms2{j}); hold on %[],toplot{j}(:,3)    
    box on
    ylabel(param1)
    xlabel(param2)
    ylim([0 10]);
    xlim([0 10]);
end
%%
% get histograms for differen colony sizes

%index2 = [8 10];toplot{1} corresponds to data from outfile 1, the first

%column within toplo{1} is index(1) data
controlpErk = toplot{1};
MEKpErk = toplot{2};
colSZ = 4;
chan = 1;% 1 - pERK, 2 - Smad2
for k=1:colSZ;
a = find(controlpErk(:,3)==k); % third column is the clony size
figure(1),histogram(controlpErk(a,chan),'normalization','pdf');hold on;
figure(2),histogram(MEKpErk(a,chan),'normalization','pdf');hold on
end
figure(1), title('Control uColonies');ylabel('Frequency');xlim([0 15]); %ylim([0 0.5])
legend(colSZ);
figure(2), title('10 uM MEKi uColonies, 42 hr');ylabel('Frequency');xlim([0 15]);%ylim([0 0.5])
legend(colSZ);

%%
% MIXED CELLS EXPREIMTN ANALYSIS
clear toplot
clear toplot2
clear alldata
clear alldata2
h2bthresh = 1000;

nms = {'esiPluri_H2Bpluri','esiPluri_H2Bdiff'};%% H2B(488), Dapi, Sox2(555),Cdx2(647)
nms2 = {'pluri+pluri','pluri+diff'};
dapimax = 4000;
dir = '.';
index2 = [8 5];% H2B AND DAPI
toplot = cell(1,size(nms,2));
flag = 0;
ind = [10 6]; % SOX2 AND CDX2
for k=1:size(nms,2)
        filename{k} = [dir filesep  nms{k} '.mat'];
        load(filename{k},'peaks','dims','plate1');
        col = plate1.colonies;
[alldata,alldata2] = SortCellsbyExpressionAN(peaks,col,index2,flag,ind,dapimax,h2bthresh);
 
 toplot{k} = alldata;    % for all the cells: alldata has following columns(index2(1) index2(2) ncell ind(1) ind(2) )
 toplot2{k} = alldata2;  % alldata2 contains only cells that are within mixed colonies, same columns (index2(1) index2(2) ncell ind(1) ind(2) )
end
%%
%MIXED CELL EXPERIMENT
% plot the analysis for the esi and h2b cells separately , excluding the
%  cells that are within mixed clonies
clear dataforesicells
clear dataforeh2b
clear r
clear r2
clear torm

k = 2; % k = 2 for the (esipluri+h2bdiff); k = 1 for (esipluri+h2bpluri)

alldata = toplot{k};
% now need to sort the all data into h2b and esi cells

% here need to remove the cells that are within the mixed colonies, to
% leave only the cells that are of the same type
[torm,ia,ib] = intersect(alldata,alldata2,'rows'); % ia are the row coordiantes of the repeating values in alldata to be removed

% test = alldata(ia,:);                   % to test that indeed found the rows that are
% tt = intersect(test,alldata2,'rows');

alldata(ia,:)=[];  % at this point the alldata contains nly the coloniues that are either only esi or h2b, without the mix

[r,~] = find(alldata(:,1)>h2bthresh); % cells that have high levels of H2B
[r2,~] = find(alldata(:,1)<h2bthresh);% cells that have background expression in GFP channel (esi cells)

dataforesicells = alldata(r2,:);
dataforeh2b = alldata(r,:);

esiSox2 = mean(dataforesicells(:,4));
esiCdx2 = mean(dataforesicells(:,5));

h2bSox2 = mean(dataforeh2b(:,4));
h2bCdx2 =  mean(dataforeh2b(:,5));
% plot mean values of Sox2 and Cdx2 for each cell type separately

figure(1), plot([esiSox2 h2bSox2],'-*');
hold on;plot([esiCdx2 h2bCdx2],'-r*');
title('Excluding mixed colonies, same chip ');

xlim([0 3]);
ylim([0 1.5]);

h = figure(1);
h.Children.XTick = [1 2];
h.Children.XTickLabel = {'esi','h2b differentaited'};
if k == 1
  h.Children.XTickLabel = {'esi pluri ','h2b pluri'};
end
title('same chip')
legend('Sox2','Cdx2');
ylabel('Mean expression');

% scatter plot of esi and h2b cells separately , color by cell type
figure(2), subplot(1,2,1), scatter(dataforeh2b(:,4),dataforeh2b(:,5),'*b'); % 4 - (ind(1); 5 - ind(2) 3 - colony size the cell belongs to
xlim([0 4]);
ylim([0 1.5]);
xlabel('sox2');
ylabel('Cdx2');
title('Excluding mixed colonies, same chip ');
legend('H2B ');
subplot(1,2,2), scatter(dataforeh2b(:,4),dataforeh2b(:,5),[],dataforeh2b(:,3)); % 4 - (ind(1); 5 - ind(2) 3 - colony size the cell belongs to
xlabel('sox2');
ylabel('Cdx2');
title('Excluding mixed colonies, same chip');
xlim([0 4]);
ylim([0 1.5]);
legend('H2B ');

figure(3),subplot(1,2,1), scatter(dataforesicells(:,4),dataforesicells(:,5),'m');
xlim([0 4]);
ylim([0 1.5]);
xlabel('sox2');
ylabel('Cdx2');
title('Excluding mixed colonies, same chip');
legend('ESI ');
subplot(1,2,2), scatter(dataforesicells(:,4),dataforesicells(:,5),[],dataforesicells(:,3));
xlabel('sox2');
ylabel('Cdx2');
title('Excluding mixed colonies, same chip');
xlim([0 4]);
ylim([0 1.5]);
legend('ESI');
% scatter plot on the same plot
figure(4), scatter(dataforeh2b(:,4),dataforeh2b(:,5),'b'); % 4 - (ind(1); 5 - ind(2) 3 - colony size the cell belongs to
hold on,  scatter(dataforesicells(:,4),dataforesicells(:,5),'m');
xlabel('sox2');
ylabel('Cdx2');
title('Excluding mixed colonies, same chip');
xlim([0 4]);
ylim([0 1.5]);
legend('h2b','esi');

%%
% MIXED CELLS ANALYSIS CONTINUED
% plot the data for the cells that are within the mixed colonies only
% all the same for the alldata2 ( contains cells that are within the colony
% of h2b+esi)
clear dataforesicells
clear dataforeh2b
clear r
clear r2
clear h2bSox2
clear h2bCdx2
clear esiSox2
clear esiCdx2

k = 2; % k = 2 for the (esipluri+h2bdiff); k = 1 for (esipluri+h2bpluri)

alldata2 = toplot2{k};

[r,~] = find(alldata2(:,1)>h2bthresh); % cells that have high levels of H2B
[r2,~] = find(alldata2(:,1)<h2bthresh);% cells that have background expression in GFP channel (esi cells)

dataforesicells = alldata2(r2,:);
dataforeh2b = alldata2(r,:);

esiSox2 = mean(dataforesicells(:,4));
esiCdx2 = mean(dataforesicells(:,5));

h2bSox2 = mean(dataforeh2b(:,4));
h2bCdx2 =  mean(dataforeh2b(:,5));
% plot mean values of Sox2 and Cdx2 for each cell type separately

figure(1), plot([esiSox2 h2bSox2],'-*');
hold on;plot([esiCdx2 h2bCdx2],'-r*');
xlim([0 3]);
ylim([0 1.5]);
h = figure(1);
h.Children.XTick = [1 2];
h.Children.XTickLabel = {'esi','h2b differentaited'};
if k ==1 
h.Children.XTickLabel = {'esi pluri ','h2b pluri'};
end
ylabel('Mean expression');
title('same chip, Mixed colonies only')
legend('Sox2','Cdx2');



% scatter plot of esi and h2b cells within the same colony , color by cell type

figure(2), subplot(1,2,1), scatter(dataforeh2b(:,4),dataforeh2b(:,5),'*b'); % 4 - (ind(1); 5 - ind(2) 3 - colony size the cell belongs to
xlim([0 4]);
ylim([0 1.5]);
xlabel('sox2');
ylabel('Cdx2');
title('Mixed Colonies only, same chip ');
legend('H2B');
subplot(1,2,2), scatter(dataforeh2b(:,4),dataforeh2b(:,5),[],dataforeh2b(:,3)); % 4 - (ind(1); 5 - ind(2) 3 - colony size the cell belongs to
xlabel('sox2');
ylabel('Cdx2');
title('Mixed Colonies only, same chip');
xlim([0 4]);
ylim([0 1.5]);
legend('H2B');

figure(3),subplot(1,2,1), scatter(dataforesicells(:,4),dataforesicells(:,5),'m');
xlim([0 4]);
ylim([0 1.5]);
xlabel('sox2');
ylabel('Cdx2');
title('Mixed Colonies only, same chip');
legend('ESI');
subplot(1,2,2), scatter(dataforesicells(:,4),dataforesicells(:,5),[],dataforesicells(:,3));
xlabel('sox2');
ylabel('Cdx2');
title('Mixed Colonies only, same chip');
xlim([0 4]);
ylim([0 1.5]);
legend('ESI');
% scatter plot on the same plot
figure(4), scatter(dataforeh2b(:,4),dataforeh2b(:,5),'b'); % 4 - (ind(1); 5 - ind(2) 3 - colony size the cell belongs to
hold on,  scatter(dataforesicells(:,4),dataforesicells(:,5),'m');
xlabel('sox2');
ylabel('Cdx2');
title('Mixed Colonies only, same chip');
xlim([0 4]);
ylim([0 1.5]);
legend('h2b','esi');


