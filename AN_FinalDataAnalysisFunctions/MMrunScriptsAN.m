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
 
 %nms = {'ESI049FullCytoo'};                  %midcoord[14 12]  fincoord[27 17]
 %nms = {'esi017FullCytoo42hr'};              %midcoord[11 18]  fincoord[19 18]
 %nms = {'esi017FullCytoo51and61hr'};         %midcoord[12 12]  fincoord[21 20]
 %nms = {'esi017_7260hr_repeat'};             %midcoord[11 9]   fincoord[22 21]
 nms = {'esi017_42hr53hr_denser'};            %midcoord[11 10]  fincoord[22 22]
 %nms = {'esi017_42hr53hr_smalldensity'} ;    %midcoord[10 10]  fincoord[22 21]
 
 
 % nms2 = {'control ','0.1 ng/ml','1 ng/ml ','10 ng/ml'};                     
 % nms2 = {'1 ng/ml(42hrs)','10 ng/ml (42hrs)' };                             
 % nms2 = {'10 ng/ml (51hr)','10 ng/ml (61hr)','1 ng/ml (51hr)','1 ng/ml(61hr)'};
 % nms2 = {'1 ng/ml (60hr)','1 ng/ml (72hr)','10 ng/ml (60hr)','10 ng/ml (72hr)'}; 
  nms2 = {'10 ng/ml (53hr)','10 ng/ml (42hr)','1 ng/ml (53hr)','1 ng/ml (42hr)'};  
 
 
[n,t] = RunAnalysisFullChipAN(0.3,4,nms,nms2,[11 10],[22 22],[6 5],[6 8],'cdx2','eomes');



    
 %%
 %scripts for the functions to run Nplot separate matfiles and plot  mean values, scatter plots, colony analysis 
 
 % [n,totalcells] = RunAnalysisQuadrantsAN(thresh,Nplot,nms,nms2,index1,index2,param1,param2)
  
 % all input arguments are equivalent to the ones above, just for the case
 % of the separate quadrants (the same meaning of index1,index2,param1,param2)
 
 
 %nms = {'H2BoutallControlMM','H2Boutall01MM','H2Boutall1MM','H2Boutall10MM'}; 
 %nms = {'Q4_1ng42hr','Q2_10ng42hr','Q3_1ng53hr','Q1_10ng53hr'}; 
 %nms = {'Q4_1ng42hr','Q2_10ng42hr','Q3gitUpdated','Q1_10ng53hr'}; 
 nms = {'esi017_30hr_1ng_repeat','esi017_42hr_1ng_repeat','esi017_30hr_10ng_repeat','esi017_42hr_10ng_repeat'};
 %nms = {'Venus_outall_001_NEW','Venus_outall_01_NEW','Venus_outall_1_NEW','Venus_outall_10_NEW'}; 
 %nms = {'ESI049BMP4atControl','ESI049BMP4at01','ESI049BMP4at1','ESI049BMP4at10'};
 %nms = {'outallcontrolH2BSignMM','outall01H2BSignMM','outall1H2BSignMM','outall10H2BSignMM'};
 %nms = {'h2bsignS2_control_MM','h2bsignS2_01_MM','h2bsignS2_1_MM','h2bsignS2_10_MM'};
 
 
 %nms2 = {'control ','0.1 ng/ml','1 ng/ml ','10 ng/ml'};    
 %nms2 = {'1ng/ml(42 hr)','10ng/ml(42 hr)','Q31ng/ml(53 hr)','10ng/ml(53 hr)'};
 %nms2 = {'1ng/ml(42 hr)','10ng/ml(42 hr)','Q3updatedcode1ng/ml(53 hr)','10ng/ml(53 hr)'};
 nms2 = {'esi017(30 hr 1 ng/ml)','esi017(42 hr 1 ng/ml)','esi017(30 hr 10 ng/ml)','esi017(42 hr 10 ng/ml)'};  
 %nms2 = {'h2bSignControl','h2bSign 0.1 ng/ml','h2bsign 1 ng/ml','h2bsign 10 ng/ml'};
 
      
             
    [a,totalcells]= RunAnalysisQuadrantsAN(0.3,4,nms,nms2,[6 5],[6 8],'cdx2','eomes');
  
   
%%
% script to optimize the segmentation parameters. Can look at a chse image
% and adjust the parameters. N is a linear index, image number
% need to be one directory up from the actual images folder ( since using
% the readMMdirectory function here)
 N =320

ANrunOneMM('esi017_7260hr_1',N,bIms,nIms,'setUserParamAN20X','DAPI');
%
%%
%to run the full set of images (obtained from the MM software)
%note: peaks to colonies is now the only function used: the choice between
%single cell and circular large colonies is done within the peakstocolonies
%function

 runFullTileMM('Q1_AN_(10ng_53hr)','Q1testcolchoice','setUserParamAN20X');
 
%function runFullTileMM(direc,outfile,paramfile,step)
