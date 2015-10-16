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
    
   [dapi,a,r1,r2,b]= plotallanalysisAN(4,nms,nms2,dir,[],[],[8 5],[8 6],'Sox2','Cdx2',0,1);
   figure(5)
   for k=1:3
       subplot(1,3,k)
      ylim([0 2200])
      xlim([0 12])
   end
   figure(6)
   for k=1:3
       subplot(1,3,k)
      ylim([0 4])
      xlim([0 10])
   end
   figure(2)
   for k=3:4
       subplot(1,4,k)
       xlim([0 0.8])
       ylim([0 10])
   end
    % [] = plotallanalysisAN(thresh,nms,nms2,dir,midcoord,fincoord,index1,index2,param1,param2,plottype,flag)
%[newdata,totalcells,ratios,ratios2,totcol] = plotallanalysisAN
 % [a, b] =   findcolonyAN(dir,2,[1 3],nms,1,[10 5],3,1,15,0);
%%
% script to optimize the segmentation parameters. Can look at a chse image
% and adjust the parameters. N is a linear index, image number
% need to be one directory up from the actual images folder ( since using
% the readMMdirectory function here)
 N =367;

 ANrunOneMM('GFPSmad4cells20hr10ngml_1',N,bIms,nIms,'setUserParamAN20X','DAPI',1);
% imcontrast

%%
% PLOT STUFF
  
%  nms = { 'esi017noQd_C_finerConc','esi017noQd_01_finerConc','esi017noQd_03_finerConc','esi017noQd_1_finerConc','esi017noQd_3_finerConc','esi017noQd_10_finerConc','esi017noQd_30_finerConc'};
%   nms2 = {'control','0.1 ng/ml','0.3 ng/ml','1 ng/ml','3 ng/ml','10 ng/ml','30 ng/ml'}; 
%   nms = {'GFPsmad4RFPh2b_20hr_10ngml'};
%   nms2 = {'20hr 10 ng/ml bmp4 grpSmad4 cells' };

  nms = {'(Rerun_Control)SignalingR2_1hr','(03ngml)SignalingR2_1hr','(3ngml)SignalingR2_1hr'};
  nms2 = {'Control 10hrs','03 ng/ml bmp4','3 ng/ml bmp4' }; 
 
 dir = '.';
   colors = {'k','m','b','g','r','y'};
   %[smad4,totalcells,r1,r2,b]= plotallanalysisAN(0.5,nms,nms2,dir,[],[],[8 5],[8 6],'Smad1','pSmad1',0,1);
   for k=1:6
  [newdata2] = MeanDecomposedbyColAN(nms,nms2,dir,[],[],[8 5],'pSmad1',0,k);
   errorbar(newdata2(:,1),newdata2(:,2),colors{k});hold on
   set(gca,'Xtick',1:size(nms2,2));
   set(gca,'Xticklabel',nms2);
   end
  
    
   
   
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
% test the watershed within the runSegmentCellsZstack
direc = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/SingleCellSignalingAN_20150805_123245 PM';

%runSegmentCellsZstack(direc,pos,chan,paramfile,outfile,nframes)

ff=readAndorDirectory(direc);
pos = 15;
chan = ff.w;
frametouse = ff.t(1);
se = 5;
flag = 1;

% filename = getAndorFileName(ff,pos,ff.t(1),ff.z(4),chan(1));
% nuc = imread(filename);
nuc=andorMaxIntensity(ff,pos,frametouse,chan(1));

for xx=2:length(chan)
            fimg(:,:,xx-1)=andorMaxIntensity(ff,pos,frametouse,chan(xx));
%             non_nucfilename = getAndorFileName(ff,pos,ff.t(1),ff.z(4),chan(xx));
%             fimg(:,:,xx-1) = imread(non_nucfilename);
end
%         
[statsnuc,statscyto,Lnuc,Lcyto] = WatershedsegmCytoplasm(nuc,fimg,se,flag); 
% 
%  try 
%         [statsnuc,statscyto,Lnuc,Lcyto] = WatershedsegmCytoplasm(nuc,fimg,se,flag);    %AN 
%         outdat = 
%         %outdat content: [x, y, nuclear_area, ones(place holder), nuc_marker_avr, nuc_smad_avr, non_nuc_smad_avr]
%     catch err
%         disp(['Error with image ' int2str(ii) ' continuing...']);
%         peaks{ii}=[];
%         statsArray{ii}=[];
%         %rethrow(err);
%         continue;
%     end

