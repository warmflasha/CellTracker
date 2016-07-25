    %%
% determine the background images(for all chnnels) for the dataset to run
ff=readMMdirectory('control_sox2cdx2');
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
    
% inhibitors with BMP1, FGFRi and control: staining: Cdx2, Nanog, Sox2
%%
% script to optimize the segmentation parameters. Can look at a chse image
% and adjust the parameters. N is a linear index, image number
% need to be one directory up from the actual images folder ( since using
% the readMM2irectory function here)
% 
% MIXED CELLS EXPERIMENT: CUTOFF FOR DAPI : < 5000; same for the
% inhibtors(2)experiment, with FGFRi
%close all
%for k=8:5:25
 N  =80;% 165
 
   ANrunOneMM('uCol_42hrMEKi',N,bIms,nIms,'setUserParamAN20X_uCOL','DAPI',1);%setUserParamAN20X_uCOL
imcontrast
%end
 

%%
clear all
% PLOT STUFF
   
%  nms = {'Control_pAktdyn','FGFRi_1hr_pAktdyn','FGFRi_6hr_pAktdyn','FGFRi_24hr_pAktdyn','FGFRi_30hr_pAktdyn','FGFRi_42hr_pAktdyn'}; 
%  nms2 = {'control','1 hr','6 hr','24 hr', '30 hr', '42 hr'};%  nanog(555) peaks{}(:,8), pERK(488) peaks{}(:,6)
   
 nms = {'C_uCol_sameImgaqsettings','MEKi42hr_uCol_sameImgaqsettings'}; 
 nms2 = {'Control uCol','MEKi 42hr uCol'};
 % nanog(RFP)peaks(8), pERK(GFP)peaks(6)
 
dapimax = 6000;%1400

dir = '.';
%colors = {'c','c','b','b','g','g','m','m','r','r'};
%colors = colorcube(10);
%[dapi,totalcells,ratios,ratios2,totcol]= plotallanalysisAN(0.5,nms,nms2,dir,[],[],[5 3],[5 3],' DAPI * CELL AREA ','area',0,1);
% for the ibidi 8well plte with pAKT staining GFP = peaks{}(:,6); RFP - peaks{}(:,8)

% gabby: three channels dapi(peaks{(:,5)} GFP(pERK) peaks{}(:,6) RFP(nanog) peaks{}(:,8)

[dapi,~,~,~,~]= plotallanalysisAN(0.6,nms,nms2,dir,[],[],[6 5],[8 6],'pERK','Oct4',0,1,dapimax);  % nanog(RFP)peaks(8), pERK(GFP)peaks(6) Dapi(5) GFP(6) RFP(8)

title('ibidi vs uCol expression levels, different NANOG ab (M vs G)')

%%
% obtain the scatter plots directly from the peaks of all the datasets in
% nms, 
%  nms = {'Control_pAktdyn','FGFRi_1hr_pAktdyn','FGFRi_6hr_pAktdyn','FGFRi_24hr_pAktdyn','FGFRi_30hr_pAktdyn','FGFRi_42hr_pAktdyn'}; 
%  nms2 = {'control','1 hr','6 hr','24 hr', '30 hr', '42 hr'}; %  nanog(555) peaks{}(:,8), pERK(488) peaks{}(:,6)
   
 nms = {'C_medchange_ibidi_sameImgaqsettings','C_uCol_sameImgaqsettings','MEKi42hr_ibidi_sameImgaqsettings','MEKi42hr_uCol_sameImgaqsettings'};  
 nms2 = {'Controll ibidi (med change)','Control uCol', 'MEKi 42hr ibidi (no med change)','MEKi 42hr uCol (no med change)'};
 % nanog(RFP), pERK(GFP)
param1 = 'Cdx2';
param2 = 'Sox2';
index2 = [6 8];
flag3 = 1; % 0 if don't want to normalize to dapi, 1  or empty = do normalize to dapi
% scatter plot of index2(1) vs index2(2) for the dataset nms2{1}
[b,c] = GeneralizedScatterAN(nms,nms2,dir,[],[],index2,param2,param1,0,flag3);

%b{k} : k runs from 1:size(nms2,2)
% cell array b contains all the normalized values of intex2(1) 
% cell array c contains all the normalized values of index1(2) 
for k=1:size(nms2,2)
figure(10), subplot(1,size(nms2,2),k), scatter(b{k},c{k},[],c{k});
xlim([0 8]);
ylim([0 8]);
%colorbar
xlabel(['Normalized  ' num2str(param1)]);
ylabel(['Normalized  ' num2str(param2)]);
box on
legend(nms2{k});
end

%%
n = 2;
figure(6)
for k=1:n
subplot(1,n,k)
ylim([0 5.5]);
xlim([0 7])

end

%%
% plot the scatter plots colorcoded
index2 = [8 6];
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
    figure(8),subplot(1,size(nms,2),j),scatter(toplot{j}(:,2),toplot{j}(:,1),[],toplot{j}(:,3),'LineWidth',2);hold on % color with: set{}(:,1) - SOx2 subplot(1,7,j)
    legend(nms2{j});
    box on
    ylabel('Sox2')
    xlabel('Cdx2')
      ylim([0 12]);
      xlim([0 12]);
end
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


%%
% CLEAN UP THIS CODE
%plot mean expression or selected colony size, plot for different datasets

nms = {'PluriNtwInh_Control','PluriNtwInh_FGFinhibited'}; % Pluri Ntw Inhibited Sox2 Nanog Cdx2
nms2 = {'Control','FGF inhibited'};
dir = '.';
thresh = 2.5;

cellnumber = {'1','2','3','4','5'};%,
% vect = [0 0.1 0.3 1 3 10 30];
% vect = [0 1 ];
colors = jet(length(cellnumber));

for k=1:5
[newdata2] = MeanDecomposedbyColAN(nms,nms2,dir,[],[],[10],'Sox2',0,k,0);
figure(4),plot(newdata2(:,3),'*','color',colors(k,:),'markersize',20);

hold on
ylim([0 10000]);
xlim([0 6]);
ylabel('Nanog')

legend(cellnumber); 
end    
  set(gca,'Xtick',1:size(nms2,2));
set(gca,'Xticklabel',nms2);
title('Mean expression')
   
%%

%to run the full set of images (obtained from the MM software)
%note: peaks to colonies is now the only function used: the choice between
%single cell and circular large colonies is done within the peakstocolonies
%function

 runFullTileMM('Control(Sox2BraCdx2)_1','esi017noQd_C_finerConc.mat','setUserParamAN20X');
 runFullTileMM('01ngml(Sox2BraCdx2)_1','esi017noQd_01_finerConc.mat','setUserParamAN20X');

runFullTileMM('03ngml(Sox2BraCdx2)_1','esi017noQd_03_finerConc.mat','setUserParamAN20X');

runFullTileMM('1ngml(Sox2BraCdx2)_1','esi017noQd_1_finerConc.mat','setUserParamAN20X');

runFullTileMM('3ngml(Sox2BraCdx2)_1','esi017noQd_3_finerConc.mat','setUserParamAN20X');

runFullTileMM('10ngml(Sox2BraCdx2)_1','esi017noQd_10_finerConc.mat','setUserParamAN20X');

runFullTileMM('30ngml(Sox2BraCdx2)_1','esi017noQd_30_finerConc.mat','setUserParamAN20X');

disp('Successfully ran all files');
%function runFullTileMM(direc,outfile,paramfile,step) %%
%%
% script to rerun the data without the nImn in the runFullTileMM;
% this script is to rerun the data from the NoQuadrantsAtAll (Repeat)
runFullTileMM('2015-08-06-NoQdrAtAll(control1)Cdx2etc_1','esi017noQd_C1_repeat(nonIms).mat','setUserParamAN20X');

 runFullTileMM('2015-08-06-NoQdrAtAll(control2)EomNanogOct_1','esi017noQd_C2_repeat(nonIms).mat','setUserParamAN20X');

runFullTileMM('2015-08-06-NoQdrAtAll(1ngmlBmp4)cdx2sox2bra_1','esi017noQd_1_repeat(nonIms).mat','setUserParamAN20X');

runFullTileMM('2015-08-06-NoQdrAtAll(10ngmlBmp4)cdx2sox2bra_1','esi017noQd_10_repeat(nonIms).mat','setUserParamAN20X');

disp('Successfully ran all files');


%%

% script to rerun the data without the nImn in the runFullTileMM;
% this script is to rerun the data from the NoQuadrantsAtAll Original
% experiment
runFullTileMM('2015-27-05-FullChipControl(Sox2)_1','esi017noQd_C2_(nonIms).mat','setUserParamAN20X');

 runFullTileMM('2015-27-05-FullChipControl(Cdx2etc)_1','esi017noQd_C1_(nonIms).mat','setUserParamAN20X');

runFullTileMM('2015-28-05-FullChip1ngml(Cdx2etc)_1','esi017noQd_1_(nonIms).mat','setUserParamAN20X');

runFullTileMM('2015-28-05-FullChip10ngml(Cdx2etc)_1','esi017noQd_10_(nonIms).mat','setUserParamAN20X');

disp('Successfully ran all files');

%%
% script to run the signaling experiment data:

runFullTileMM('Esi017_Control20hr_1','esi017noQd_(C)sign20hr.mat','setUserParamAN20X');

runFullTileMM('Esi017_03ng20hr_1','esi017noQd_03ngSign20hr.mat','setUserParamAN20X');

runFullTileMM('Esi017_3ng20hr_1','esi017noQd_3ngSign20hr.mat','setUserParamAN20X');

disp('Successfully ran all files');
%%
% script to run the REPEATED Signaling Experiment data (pSmad1 is very
% good)
runFullTileMM('Control20hr_1','e017noQd_C_signR20hr_Imging2.mat','setUserParamAN20X');

runFullTileMM('03ngml_20hr_1','e017noQd_03ngml_signR20hr_Imging2.mat','setUserParamAN20X');
%%

runFullTileMM('3ngml_20hr_1','e017noQd_3ngml_signR20hr_Imging2(paramfilecorrect).mat','setUserParamAN20X'); % corrected

disp('Successfully ran all files');


%%

runFullTileMM('03ngml_1hrRSign_2','e017noQd_03ngml_signR1hrImg2.mat','setUserParamAN20X');

runFullTileMM('3ngml_1hrRSign_1','e017noQd_3ngml_signR1hrImg2.mat','setUserParamAN20X');

disp('Successfully ran all files');
%%


direc = 'Pos0';
[outdat, nuc, fimg]=runOneMMDirec(direc,'setUserParamAN20X','DAPI');
imshow(nuc,[]);
hold on;
plot(outdat(:,1),outdat(:,2),'r*');
%%
superdir  = '03ngml20hr(manualJul21)_1';
outdat = runMultipleMMDirec(superdir,'setUserParamAN20X','DAPI');
save 03ngml20hrMAN(2).mat outdat;
%%

runFullTileMM('Control_1','(C)inhibitors_area1.mat','setUserParamAN20X');
runFullTileMM('Control(area2)_1','(C)inhibitors_area2.mat','setUserParamAN20X');
runFullTileMM('Control(area3)_1','(C)inhibitors_area3.mat','setUserParamAN20X');
runFullTileMM('BMPinhibitor(area1)_1','BMPinh_area1.mat','setUserParamAN20X');
runFullTileMM('BMPinhibitor(area2)_1','BMPinh_area2.mat','setUserParamAN20X');
runFullTileMM('BMPinhibitor(area3)_1','BMPinh_area3.mat','setUserParamAN20X');
runFullTileMM('WNTinhibitor(area1)_1','WNTinh_area1.mat','setUserParamAN20X');
runFullTileMM('WNTinhibitor(area_2)_1','WNTinh_area2.mat','setUserParamAN20X');

disp('Successfully ran all files');

%%
%
%% run the new Imaging4 signaling(repeat) experiment

runFullTileMM('signControl_1hr_1','(C)SignalingR_1hr(Imging4).mat','setUserParamAN20X');

runFullTileMM('signControl_20hr_1','(C)SignalingR_20hr(Imging4).mat','setUserParamAN20X');

runFullTileMM('sign03_1hr_1','(03ngml)SignalingR_1hr(Imging4).mat','setUserParamAN20X');

runFullTileMM('sign3_1hr_1','(3ngml)SignalingR_1hr(Imging4).mat','setUserParamAN20X');

runFullTileMM('sign03_20hr_1','(03ngml)SignalingR_20hr(Imging4).mat','setUserParamAN20X');

runFullTileMM('sign3_20hr_1','(3ngml)SignalingR_20hr(Imging4).mat','setUserParamAN20X');


disp('Successfully ran all files');
%% run the new signaling(repeat2,R2) experiment
% the september repeat, clean( 1 hour dataset)
runFullTileMM('2015-09-14-Signaling(R2)_3ngml_1hr_1','(3ngml)SignalingR2_1hr.mat','setUserParamAN20X');

runFullTileMM('2015-09-14-Signaling(R2)_03ngml_1hr_2','(03ngml)SignalingR2_1hr.mat','setUserParamAN20X');

runFullTileMM('2015-09-14-Signaling(R2)_control_1hr_1','(Control)SignalingR2_1hr.mat','setUserParamAN20X');% out of focus, need to rerun


runFullTileMM('2015-09-18-Signaling(R2)_control_1hr_1','(Rerun_Control)SignalingR2_1hr_analysis2.mat','setUserParamAN20X');% rerun of this chip, better AF

disp('Successfully ran all files');

%% run the Lili experiment 1 (dynamic ligand presentation)Initial volume in the dishes is 2 ml and changing to calculated 8 ml
% which was impossible to fit at the last time point. Final volume was 6
% ml. Concentrations of BMP4 changed from 0.5 ng/ml to 2 ng/ml The control
% off had no BMP4
% 
runFullTileMM('ControlOff_1','ControlOff(Lili1).mat','setUserParamAN20X');

runFullTileMM('ControlON_1','ControlON(Lili1).mat','setUserParamAN20X');

runFullTileMM('Decreasing_t0_2ngml_1','DecreasingBMP4(Lili1).mat','setUserParamAN20X');

runFullTileMM('Increasing_t0_05ngml_1','IncreasingBMP4(Lili1).mat','setUserParamAN20X');

disp('Successfully ran all files');

%% run the Lili experiment 2 (dynamic ligand presentation, the initial volume in all dizhes is 1 ml and changing up to 4 ml)
% concentrations change from 0.5 ng/ml to 2 ng/ml
% 
runFullTileMM('ControlOFF_1','ControlOFF(Lili_experiment2).mat','setUserParamAN20X');

runFullTileMM('ControlON_1','ControlON(Lili_experiment2).mat','setUserParamAN20X');

runFullTileMM('DEcreasing_1','DecreasingBMP4(Lili_experiment2).mat','setUserParamAN20X');

runFullTileMM('INCREASING_2','IncreasingBMP4(Lili_experiment2).mat','setUserParamAN20X');

disp('Successfully ran all files');
%% run the Lili experiment 3 (dynamic ligand presentation, Volume Test, initial volume 1 ml in the dishes where it changes)
% if the volume does not change, then it started from 4 ml
% BMP4 concentrations change from 0.5 ng/ml to 2 ng/ml
% 
runFullTileMM('ControlOFFVinit4ml_1','C_off_Vinit_4ml.mat','setUserParamAN20X');

runFullTileMM('ControlOFFVinit_1_ml_1','C_off_Vinit_1ml.mat','setUserParamAN20X');

runFullTileMM('IncereasingVinit_1ml_1','Increase_Vinit_1ml.mat','setUserParamAN20X');

runFullTileMM('IncereasingVinit_4ml(2)_2','Increase_Vinit_4ml.mat','setUserParamAN20X');

disp('Successfully ran all files');
%%
% to run the community effect WNT experiment 
% Septermber 24, 2015

runFullTileMM('2015-09-22-Control(wntexperiment)_1','CommEffWntExperiment_Control.mat','setUserParamAN20X');

runFullTileMM('2015-09-22-WNTactCHIRR_1','CommEffWntExperiment_actCHIRR.mat','setUserParamAN20X');

runFullTileMM('2015-09-22-WNTinhibit(IWP2)_1','CommEffWntExperiment_inhIWP2.mat','setUserParamAN20X');

disp('Successfully ran all files');

%%
% to run the WNT activation experiment(control and 0.2 uM of CHIRR) 
% October 12, 2015, experiment done the previous week

runFullTileMM('Control_1','WntAct_control_notwellpatterned.mat','setUserParamAN20X');

runFullTileMM('2015-09-10-CHIRR02uM(2)_1','WntAct_CHIRR02uM_notwellpatterned.mat','setUserParamAN20X');

disp('Successfully ran all files');
%%
runFullTileMM('GFPSmad4cells20hr10ngml_1','GFPsmad4RFPh2b_20hr_10ngml.mat','setUserParamAN20X');

disp('Successfully ran all files');

%%
% run the RI experiment
runFullTileMM('WITH_Rhoi_3ngmlBmp4_1','With_RIplus3ngmlBmp4.mat','setUserParamAN20X');
runFullTileMM('NO_Rhoi_3ngmlBmp4_1','NO_RIplus3ngmlBmp4.mat','setUserParamAN20X');

disp('Successfully ran all files');


%%
% run the siRNA nodal experiment
runFullTileMM('siRNAnodalNegControl_1','siRNAnodalNegativeC(pluri).mat','setUserParamAN20X');
runFullTileMM('siRNAnodal(pluri)2_1','siRNAnodal(pluri).mat','setUserParamAN20X');

disp('Successfully ran all files');

%%
% march 2016 Inhibitors experiment
runFullTileMM('extracted_Control','Control(R).mat','setUserParamAN20X');
runFullTileMM('extracted_BMPi','BMPi.mat','setUserParamAN20X');

disp('Successfully ran all files');

%%
%FGF in dofferentiated conditions and community effect
% 2016-03-23 (march 23)

runFullTileMM('Control_pluri_extracted','C_pluri_fgfindiff.mat','setUserParamAN20X');
runFullTileMM('Control_diff3ngml_extracted','C_diff_fgfindiff.mat','setUserParamAN20X');
runFullTileMM('3ngmlBMP4withFGFi_extracted','FGFi_BMP4_fgfindiff.mat','setUserParamAN20X');


disp('Successfully ran all files');



%%
% 
% Oct4 - 647; 488 - pERK; 555 - Bra

runFullTileMM('extracted_FGFi','FGFi.mat','setUserParamAN20X');% march 2016 Inhibitors experiment


disp('Successfully ran all files');
%%
% to plot Lili first experiment data% 647 - CDX2; 488 - Sox2; 555 - Bra
  figure(2)
%   title('Volume Test')
   for k=1:4
       subplot(1,4,k)
       xlim([0 16])
       ylim([0 6])
   end
 
 nms = {'ControlOFF(Lili_experiment2)','ControlON(Lili_experiment2)','DecreasingBMP4(Lili_experiment2)','IncreasingBMP4(Lili_experiment2)'};

 nms2 = {'ControlOff','ControlON','Decreasing','Increasing'};
 
 dir = '.';
    
   [s1,totalcells,r1,r2,b]= plotallanalysisAN(0.4,nms,nms2,dir,[],[],[8 5],[8 10],'Sox2','Bra',0,1);
%%
% running dynamics data (ran on Monday, November 30, 2015
% all data sets were obtained with 5% overlap
%cd('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2015-11-13-CellSense/Dynamics/Control_tifs');
runFullTileMM('Dynamics_C','Dynamics_C(R).mat','setUserParamAN20X');

%cd('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2015-11-13-CellSense/Dynamics/20hr_tifs');
runFullTileMM('Dynamics_20hr(R)','Dynamics_20hr5gnml(R).mat','setUserParamAN20X');

%cd('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2015-11-13-CellSense/Dynamics/27hr_tifs');
runFullTileMM('Dynamics_27hr(R)','Dynamics_27hr5gnml(R).mat','setUserParamAN20X');

%cd('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2015-11-13-CellSense/Dynamics/33hr_tifs');
runFullTileMM('Dynamics_33hr(R)','Dynamics_33hr5gnml(R).mat','setUserParamAN20X');

%cd('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2015-11-13-CellSense/Dynamics/42hr_tifs');
runFullTileMM('Dynamics_42hr(R)','Dynamics_42hr5gnml(R).mat','setUserParamAN20X');

disp('Successfully ran all files');

%%
% running the Pluri Network Inhibition experiments (ran December 1, 2015)
% last two sets were obtained with 0% overlap (first two - with 5% overlap
% in the case of 0% overlap the bIms look much better and uniform
runFullTileMM('PluriNtwInh_Control','PluriNtwInh_Control.mat','setUserParamAN20X');

runFullTileMM('PluriNtwInh_FGFinhibited','PluriNtwInh_FGFinhibited.mat','setUserParamAN20X');

runFullTileMM('PluriNtwInh_Furin(nodal_Inh)','PluriNtwInh_Furin(nodal_Inh).mat','setUserParamAN20X');

runFullTileMM('PluriNtwInh_PI3Kinhibited','PluriNtwInh_PI3Kinhibited.mat','setUserParamAN20X');

disp('Successfully ran all files');
%%
% April 2016 Mixed Experiment run ( esi+h2b)

runFullTileMM('esiPluri_H2BPluri_extracted','esiPluri_H2Bpluri.mat','setUserParamAN20X');

runFullTileMM('esiPluri_H2BDiff_extracted','esiPluri_H2Bdiff.mat','setUserParamAN20X');

disp('Successfully ran all files');
%%
% inhibitors experimnt repeat, April 2016 ( done tigether with the Mixed
% experiment)
% control, bmpi, FGFri
% not very good seeding
runFullTileMM('control_extracted','Control_inh(2).mat','setUserParamAN20X');
runFullTileMM('bmpi_extracted','BMP_inh(2).mat','setUserParamAN20X');
runFullTileMM('FGFRi_extracted','FGFReceptor_inh.mat','setUserParamAN20X');

disp('Successfully ran all files');

%%
% ibidi slides run ( 24 hr, XP antibody)

runFullTileMM('C_for_FGFi_24hrXP','C_24hr_FGFi_XP.mat','setUserParamAN20X');
runFullTileMM('C_for_FGFRi_24hrXP','C_24hr_FGFRi_XP.mat','setUserParamAN20X');
runFullTileMM('FGFi_24hrXP','FGFi_24hr_XP.mat','setUserParamAN20X');
runFullTileMM('FGFRi_24hrXP','FGFRi_24hr_XP.mat','setUserParamAN20X');


disp('Successfully ran all files');
%%
% ibidi slides run ( 6 hr, XP antibody) Nanog stain added

runFullTileMM('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-04-27-CMvsMtesrFGFigraded/CM/cm_control','cm_control.mat','setUserParamAN20X');
runFullTileMM('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-04-27-CMvsMtesrFGFigraded/CM/cm_FGFi10uM','cm_FGFi10uM.mat','setUserParamAN20X');
runFullTileMM('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-04-27-CMvsMtesrFGFigraded/CM/cm_FGFi30uM','cm_FGFi30uM.mat','setUserParamAN20X');
runFullTileMM('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-04-27-CMvsMtesrFGFigraded/CM/cm_FGFRi200nM','cm_FGFRi200nM.mat','setUserParamAN20X');
%mt
runFullTileMM('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-04-27-CMvsMtesrFGFigraded/Mtesr/mt_control','mt_control.mat','setUserParamAN20X');
runFullTileMM('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-04-27-CMvsMtesrFGFigraded/Mtesr/mt_FGFi10uM','mt_FGFi10uM.mat','setUserParamAN20X');
runFullTileMM('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-04-27-CMvsMtesrFGFigraded/Mtesr/mt_FGFi30uM','mt_FGFi30uM.mat','setUserParamAN20X');
runFullTileMM('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-04-27-CMvsMtesrFGFigraded/Mtesr/mt_FGFRi200nM','mt_FGFRi200nM.mat','setUserParamAN20X');


disp('Successfully ran all files');

%%
% inhibitors experimentwith good pERK AB (uColonies)
% chips imaged on may 12, 2016

runFullTileMM('Control_perknanogcdx2','C_pERKnanogCDX2.mat','setUserParamAN20X');

runFullTileMM('FGFi_20uM','20uM_MEKi_pERKnanogCDX2.mat','setUserParamAN20X');

runFullTileMM('Lefty_500ngml','500ngml_Lefty_pERKnanogCDX2.mat','setUserParamAN20X');

disp('Successfully ran all files');

%%
% ibidi, pAKT ab reponse test: June 13 imaging 6 hr ibidi row
% 

runFullTileMM('control_24','control_24hr.mat','setUserParamAN20X');
runFullTileMM('LY_24hr','PI3Ki_via_LY10uM_24hr.mat','setUserParamAN20X');
runFullTileMM('MEKi_24hr','FGFi_via_MEKi10uM_24hr.mat','setUserParamAN20X');
runFullTileMM('FGFRi_24hr','FGFRi_24hr.mat','setUserParamAN20X');


disp('Successfully ran all files');
%%
% FucciG1 cells
% control and 10 ng/ml BMP4
runFullTileMM('FucciG1_control','FucciG1_control42hr.mat','setUserParamAN20X');

runFullTileMM('FucciG1_BMP410ngml','FucciG1_BMP410ngml42hr.mat','setUserParamAN20X');


disp('Successfully ran all files');

%%
% run the pAkt dynamics
runFullTileMM('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-07-15-pAkt_DYN(Gabby)pAktNanogSmad2/contol_pAktdyn','Control_pAktdyn.mat','setUserParamAN20X');
runFullTileMM('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-07-15-pAkt_DYN(Gabby)pAktNanogSmad2/1hr_pAktdyn','FGFRi_1hr_pAktdyn.mat','setUserParamAN20X');
runFullTileMM('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-07-15-pAkt_DYN(Gabby)pAktNanogSmad2/6hr_pAktdyn','FGFRi_6hr_pAktdyn.mat','setUserParamAN20X');
runFullTileMM('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-07-15-pAkt_DYN(Gabby)pAktNanogSmad2/24hr_pAktdyn','FGFRi_24hr_pAktdyn.mat','setUserParamAN20X');
runFullTileMM('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-07-15-pAkt_DYN(Gabby)pAktNanogSmad2/30hr_pAktdyn','FGFRi_30hr_pAktdyn.mat','setUserParamAN20X');
runFullTileMM('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-07-15-pAkt_DYN(Gabby)pAktNanogSmad2/42hr_pAktdyn','FGFRi_42hr_pAktdyn.mat','setUserParamAN20X');

disp('Successfully ran all files for ibidi pAkt');

runFullTileMM('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-07-16-uCol_MEKi10uM_pERKNanogSmad2/control_pERKnanogSmad2','C_R_pErkNanogSmad2.mat','setUserParamAN20X_uCOL');
runFullTileMM('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-07-16-uCol_MEKi10uM_pERKNanogSmad2/MEKi_pERKnanogSmad2','MEKi_R_pErkNanogSmad2.mat','setUserParamAN20X_uCOL');


disp('Successfully ran all files for uCol analysis');


