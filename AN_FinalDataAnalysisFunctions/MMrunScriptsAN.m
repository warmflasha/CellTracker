%%
 %  [n,totalcells] = RunAnalysisFullChipAN(thresh,Nplot,nms,nms2,midcoord,fincoord,index1,index2,param1,param2)
 % function RunAnalysisFullChipAN produces 5 figures ( meav values, scatter
 % plot and three colony-analysis related plots)
 % see descriptions below and within each function
 
 % Nplot - number of parts of the chip to plot (usually 4)
 % midcoord - defines the imagenumbers which separate the two quadrants (1,1) and (1,2) in
 % x direction (1,1) and (2,1) in y direction. Need to check these image numbers while setting up the grid
 % before aquisition
 % fincoord - define the imagenumbers of the last images taken in x and y
 % directions. Also need to check these and record while setting up the grid
 % on the microscope.( also they are obvious if use mkCytooPLotPeaks)
 % index1 - specifies which peaks' column to use. If index has two components
 % [ index1(1) index1(2)] - the ratio of the columns is plotted.
 % index2 = the column of the 'peaks' data to plot from the matfile. if input
 % only one number - get the plot of this column = not normalized data
 % values; if input two numbers [index2(1),index2(2)], obtain scatter plot of
 % normalized index2(1)(x-axis) versus normalized index2(2)(y-axis);Normalization
 % to DAPI ( DAPI is assumed to be column 5 of peaks);
 % need to be within the directory with the matfiles
 % nms2 - cell array of strings that specifies the conditions in each
 % quadrant/ used as a label for the x axis
 % param1 - label of the y-axis, input as a string, specifies which peaks' column you
 % are plotting and what it represents ( e.g. 'Sox2 expression');
 % thresh parameter can be first input randomly small (e.g. 0.2) and then
 % adjusted based on the scatter plots for the specific gene of interest
 
 %Note: need to input manually only the midcoord, fincoord, and the peaks'
 %column number which you want to plot ( in MM data peaks{}(:,6) - cdx2) 
 
 %nms = {'ESI049FullCytoo'};                  %midcoord[14 12]  fincoord[26 17]     need to rerun the colony; mafullcytooplot looks horrible here
 %nms = {'esi017FullCytoo42hr'};              %midcoord[11 18]  fincoord[19 18]      for this only two condition at one time point were probed: Nplot = 2
 %nms = {'esi017FullCytoo51and61hr'};         %midcoord[12 12]  fincoord[21 20]
 %nms = {'esi017_7260hr_repeat'};             %midcoord[11 9]   fincoord[22 21]
 % nms = {'esi017_42hr53hr_denser'};            %midcoord[11 10]  fincoord[22 22]
% nms = {'esi017_42hr53hr_denser(2)'};          %midcoord[11 10]  fincoord[22 22]
 %nms = {'esi017_42hr53hr_smalldensity'} ;    %midcoord[10 10]  fincoord[22 21]
 %nms = {'esi017withControl42hr'};            %midcoord[10 10] or (midcoord better[12 13]) fincoord[23 21]  % most recent dataset
  %nms = {'esi017_42hrVol_1ngBMP'};     %midcoord[11 11]  fincoord[22 21]  % volume-dependent,1ng/ml label
 % nms = {'esi017_42hrVol_control(1)'};     %midcoord[10 11]  fincoord[20 21]  % volume-dependent,contro(1) label
  nms = {'esi017_42hrVol_control(2)'};       %midcoord[11 10]  fincoord[21 22]  % volume-dependent,contro(2) label
  
  %nms = {'esi017fDish_control'};    
  %nms = {'esi017fDish_1ngml'}; 
  %nms = {'esi017fDish_10ngml'}; 
      
  %nms2 = {'Sox2','pSmad1','Eomes','Gata6'};
  %nms2 = {'Oct4','Smad2','Cdx2','Cdx2'};
  %nms2 = {'Bra','Bra','Sox17','Sox17'};
  
  
  nms2 = {'100ul','150ul','200ul','225ul'};
 %nms2 = {'control ','0.1 ng/ml','1 ng/ml ','10 ng/ml'};                     
  % nms2 = {'1 ng/ml(42hrs)','10 ng/ml (42hrs)' };                             
 % nms2 = {'10 ng/ml (51hr)','10 ng/ml (61hr)','1 ng/ml (51hr)','1 ng/ml(61hr)'};
 % nms2 = {'1 ng/ml (60hr)','1 ng/ml (72hr)','10 ng/ml (60hr)','10 ng/ml (72hr)'}; 
  %nms2 = {'10 ng/ml (53hr)','10 ng/ml (42hr)','1 ng/ml (53hr)','1 ng/ml (42hr)'};  
 

    plotallanalysisAN(0.5,nms,nms2,[],[],[6 5],[6 10],'CY5','RFP',1,flag);
    
 %%
 %scripts for the functions to run Nplot separate matfiles and plot  mean values, scatter plots, colony analysis 
 
 % nms = {'H2BoutallControlMM','H2Boutall01MM','H2Boutall1MM','H2Boutall10MM'}; 
 
% nms = {'esi017fDish_control'};    
  %nms = {'esi017fDish_1ngml'}; 
  %nms = {'esi017fDish_10ngml'}; 
      
  %nms2 = {'Sox2','pSmad1','Eomes','Gata6'};
  %nms2 = {'Oct4','Smad2','Cdx2','Cdx2'};
  %nms2 = {'Bra','Bra','Sox17','Sox17'};
 %nms = { 'esi017noqdratall_control(2)','esi017noqdratall_control(cdx2)','esi017noqdratall_1ngmlBMP','esi017noqdratall_10ngmlBMP'};    % from
 %nms = { 'esi017noQd_C(2)_Repeat','esi017noQd_C(1)_Repeat','esi017noQd_1ng_Repeat','esi017noQd_10ng_Repeat'};
 %nms = { 'esi017noQd_C2_repeat(nonIms)','esi017noQd_C1_repeat(nonIms)','esi017noQd_1_repeat(nonIms)','esi017noQd_10_repeat(nonIms)'};
 
 %nms = {'esi017noQd_1hr003ng','esi017noQd_1hr03ng','esi017noQd_1hr3ng'};
% nms = { 'esi017noQd_C_finerConc','esi017noQd_01_finerConc','esi017noQd_03_finerConc','esi017noQd_1_finerConc','esi017noQd_3_finerConc','esi017noQd_10_finerConc','esi017noQd_30_finerConc'};
 
 %nms = {'esi017noQd_(C)sign20hr','esi017noQd_03ngSign20hr','esi017noQd_3ngSign20hr'};
 %nms = {'Q4_1ng42hr','Q2_10ng42hr','Q3gitUpdated','Q1_10ng53hr'}; 
 %nms = {'esi017_30hr_1ng_repeat','esi017_42hr_1ng_repeat','esi017_30hr_10ng_repeat','esi017_42hr_10ng_repeat'};
 %nms = {'Venus_outall_001_NEW','Venus_outall_01_NEW','Venus_outall_1_NEW','Venus_outall_10_NEW'}; 
 %nms = {'ESI049BMP4atControl','ESI049BMP4at01','ESI049BMP4at1','ESI049BMP4at10'};
 %nms = {'outallcontrolH2BSignMM','outall01H2BSignMM','outall1H2BSignMM','outall10H2BSignMM'};
 %nms = {'h2bsignS2_control_MM','h2bsignS2_01_MM','h2bsignS2_1_MM','h2bsignS2_10_MM'};
 
 %nms = {'esi017noqdratall_control(2)'};
 % nms2 = {'control ','10 ng/ml'};  
 %nms2 = {'control ','0.1 ng/ml','1 ng/ml ','10 ng/ml'};  
 %nms2 = {'control'};
  %nms2 = {'control','0.1 ng/ml','0.3 ng/ml','1 ng/ml','3 ng/ml','10 ng/ml','30 ng/ml'}; 
 
 %nms2 = {'control(20hr)','0.3 nm/ml(20hr)','3 ng/ml(20hr)',};
 %nms2 = {'0.03(1hr)','0.3 nm/ml(1hr)','3 ng/ml(1hr)',};
%nms2 = {'control(2)','control(1) ','1 ng/ml ','10 ng/ml'};    
 %nms2 = {'1ng/ml(42 hr)','10ng/ml(42 hr)','Q31ng/ml(53 hr)','10ng/ml(53 hr)'};
 %nms2 = {'1ng/ml(42 hr)','10ng/ml(42 hr)','Q3updatedcode1ng/ml(53 hr)','10ng/ml(53 hr)'};
 %nms2 = {'esi017(30 hr 1 ng/ml)','esi017(42 hr 1 ng/ml)','esi017(30 hr 10 ng/ml)','esi017(42 hr 10 ng/ml)'};  
 %nms2 = {'h2bSignControl','h2bSign 0.1 ng/ml','h2bsign 1 ng/ml','h2bsign 10 ng/ml'};
 
%  nms = {'esi017noQd_1hr003ng','esi017noQd_1hr03ng','esi017noQd_1hr3ng','esi017noQd_(C)sign20hr','esi017noQd_03ngSign20hr','esi017noQd_3ngSign20hr'};
%  nms2 = {'0.03(1hr)','0.3 nm/ml(1hr)','3 ng/ml(1hr)','control(20hr)','0.3 nm/ml(20hr)','3 ng/ml(20hr)'};
 %dir = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2015-06-30-Signaling(pSmad1Smad2Nanog)';
%nms = {'esi017noQd_ControlsignR20hr','esi017noQd_03ngsignR1hr','esi017noQd_3ngsignR1hr','esi017noQd_03ngsignR20hr','esi017noQd_3ngsignR20hr'};

%nms2 = { 'Control(20hrs)','03ng/ml(1hr)','3ng/ml(1hr)', '03ng/ml(20hrs)', '3ng/ml(20hrs)'};
nms = {'(C)inhibitors_area1','BMPinh_area1','WNTinh_area1'}; 
nms2 = { 'Control','BMPi','WNTi'};


 dir = '.';
    
   [dapi,a,r1,r2,b]= plotallanalysisAN(0.5,nms,nms2,dir,[],[],[5],[8 10],'Sox2','Bra',0,1);
   figure(3)
   for k=1:3
       subplot(1,2,k)
      ylim([0 1])
      xlim([0 10])
   end
   figure(3)
   for k=1:2
       subplot(1,2,k)
      ylim([0 0.1])
      xlim([0 10])
   end
   figure(6)
   for k=1:4
       subplot(1,4,k)
       xlim([0 10])
       ylim([0 1500])
   end
    % [] = plotallanalysisAN(thresh,nms,nms2,dir,midcoord,fincoord,index1,index2,param1,param2,plottype,flag)
%[newdata,totalcells,ratios,ratios2,totcol] = plotallanalysisAN
 % [a, b] =   findcolonyAN(dir,2,[1 3],nms,1,[10 5],3,1,15,0);
%%
% determine the background images(for all chnnels) for the dataset to run
ff=readMMdirectory('esiPluri_H2BDiff_extracted');
dims = [ max(ff.pos_x)+1 max(ff.pos_y)+1];
wavenames=ff.chan;

maxims= dims(1)*dims(2);

%generate background image for each channel

    for ii=1:length(wavenames) % get the background image for al channels  
        [minI, meanI]=mkBackgroundImageMM(ff,ii,min(500,maxims));
        bIms{ii}=uint16(2^16*minI);
        nIms{ii}=ones(size(bIms{ii}));
%         normIm=(meanI-minI);
%         normIm=normIm.^-1;
%         normIm=normIm/min(min(normIm));
%         nIms{ii}=normIm;
    end
    

%%
% script to optimize the segmentation parameters. Can look at a chse image
% and adjust the parameters. N is a linear index, image number
% need to be one directory up from the actual images folder ( since using
% the readMM2irectory function here)
% 
% MIXED CELLS EXPERIMENT: CUTOFF FOR DAPI : < 5000
 N =255;% 165
 
   ANrunOneMM('esiPluri_H2BDiff_extracted',N,bIms,nIms,'setUserParamAN20X','DAPI',1);
 %imcontrast
 %%
 % test some post- or -mid processing of the nuc image, to get rid of the
 % small bright stuff
   close all
   %nuc=presubBackground_self(nuc);
   global userParam
   nucbgi=imopen(nuc,strel('disk',userParam.backdiskrad));
   meanbg = mean(mean(nucbgi));
   
 nucbg1=imopen(nuc,strel('disk',10));
 nuc1=imsubtract(nuc,nucbg1);
 %nuc2=imsubtract(nuc,nuc1);
 %figure, imshow(nucbg1,[]);
 figure, imshow(nuc,[0 2000]);
 figure, imshow(nuc1,[0 2000]);
 
 
 nuc=presubBackground_self(nuc);
 
%  t = im2bw(nuc1,graythresh(nuc1));
%  t2 = im2bw(nuc,graythresh(nuc));
%  a = t2&~t;
 
 t = bwareafilt(t,[0 200]);
 tt = bwconncomp(t);
 tt.PixelIdxList; % pixels to be zeroed in the original image
 for k=1:length(tt.PixelIdxList)
 nuc(tt.PixelIdxList{k}) = meanbg;
 end
 figure, imshow(nuc,[]);
 
  % live cell data processing  
% I2proc = imopen(I2,strel('disk',userParam.small_rad));         % remove small bright stuff
% I2proc = smoothImage(I2proc,userParam.gaussRadius,userParam.gaussSigma); %smooth
% I2proc = presubBackground_self(I2proc);
 

%%
clear all
% PLOT STUFF
% nms = {'With_RIplus3ngmlBmp4','NO_RIplus3ngmlBmp4'};
% nms2 = {'plus RI diff','no RI diff'};

% nms = { 'esi017noQd_C_finerConc','esi017noQd_01_finerConc','esi017noQd_03_finerConc','esi017noQd_1_finerConc','esi017noQd_3_finerConc','esi017noQd_10_finerConc','esi017noQd_30_finerConc'};
% nms2 = {'control','0.1 ng/ml','0.3 ng/ml','1 ng/ml','3 ng/ml','10 ng/ml','30 ng/ml'};% Sox2, Cdx2, Bra
  
% nms = {'esi017noQd_(C)sign20hr','esi017noQd_03ngSign20hr','esi017noQd_3ngSign20hr'};
% nms2 = {'C(0.03 ng/ml) 20 hrs','0.3 ng/ml 20 hr','3 ng/ml 20 hr'};

% nms = {'siRNAnodalNegativeC(pluri)','siRNAnodal(pluri)'}; % sox2 nanog Cdx2
% nms2 = {'Nodal(negative Control)','siRNA Nodal (~ 15 nM)' };

% nms = {'CommEffWntExperiment_Control','CommEffWntExperiment_inhIWP2','CommEffWntExperiment_actCHIRR'};%sox2 Oct4 Nanog    
% nms2 = {'Control','WNTinhibitor','WntAct CHIRR 0.5uM' };

% nms = {'gfpS4_10ngml20hr_1'}; % dapi CY5 GFP order of channels
% nms2 = {'GFP:Smad4 cells 20hr, 10 ng/ml bmp4'};

%  nms = {'PluriNtwInh_Control','PluriNtwInh_FGFinhibited','PluriNtwInh_PI3Kinhibited','PluriNtwInh_Furin(nodal_Inh)'}; % Pluri Ntw Inhibited Sox2 Nanog Cdx2
%  nms2 = {'Control','FGFi','PI3Ki','Furin'};
  
%   nms = {'PluriNtwInh_Control(R)','PluriNtwInh_FGFi(R)'};
%   nms2 = {'control(R)','FGFi(R)'};
   
%  nms = {'FGFinCE_Control','FGFinCE_FGFhigh','FGFinCE_FGFi'}; %  pERK Nanog Cdx2,'FGFi'
%  nms2 = {'control','FGF high (100 ng/ml)','FGFi (PD98059 @ 10 uM)'};%,'FGFi at 10 uM' 
 % AB pERK test
 
%  nms = {'Control(R)','BMPi','FGFi'}; 
%  nms2 = {'C','Bi','Fgfi'};
 
 nms = {'C_pluri_fgfindiff','C_diff_fgfindiff','FGFi_BMP4_fgfindiff'};%%  Sox2 Nanog Cdx2
 nms2 = {'control pluri','control diff ( 3ng/ml BMP4)','BMP4 (3 ng/ml) + FGFi (10 uM)'};
 
%  title('Dynamics, 5 ng/ml bmp4');
dir = '.';
%colors = {'c','c','b','b','g','g','m','m','r','r'};
%colors = colorcube(10);
[dapi,totalcells,ratios,ratios2,totcol]= plotallanalysisAN(0.5,nms,nms2,dir,[],[],[5 3],[5 3],' DAPI * CELL AREA ','area',0,1);
thresh = 1;
%[dapi,totalcells,ratios,ratios2,totcol]= plotallanalysisAN(thresh,nms,nms2,dir,[],[],[6],[8 6],'Cdx2','Cdx2',0,1);
%%
% plot the scatter plots colorcoded
index2 = [8 6];
toplot = cell(1,size(nms,2));
flag = 0;
flag2 = 1;% do not normalize to DAPI if flag == 0;
for k=1:size(nms,2)
        filename{k} = [dir filesep  nms{k} '.mat'];
        load(filename{k},'peaks','dims','plate1');
        col = plate1.colonies;
[alldata] = mkVectorsForScatterAN(peaks,col,index2,flag,flag2);
 toplot{k} = alldata;
end


for j=1:size(nms,2)
    figure(7),subplot(1,size(nms,2),j),scatter(toplot{j}(:,2),toplot{j}(:,1),[],toplot{j}(:,3),'LineWidth',2);hold on % color with: set{}(:,1) - SOx2 subplot(1,7,j)
    legend(nms2{j});
    box on
    ylabel('Sox2')
    xlabel('Cdx2')
      %ylim([0 5]);
      %xlim([0 10]);
end
%%
figure(6)
   for k=1:size(nms,2)
       subplot(1,size(nms,2),k)
       h = subplot(1,size(nms,2),k);
       h.Children.MarkerSize = 15;
       xlim([0 10])
       ylim([0 6000000])
   end
   %%
   figure(3)
   for k=1:size(nms,2)
        subplot(1,size(nms,2),k)
       h = subplot(1,size(nms,2),k);
       h.Children.MarkerSize = 18;
       xlim([0 8])
       %ylim([0 5000])
   end
   
   %%
% plot mean expression or selected colony size, plot for different datasets

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

