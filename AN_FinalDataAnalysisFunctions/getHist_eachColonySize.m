nms = {'Lefty500_ucol'};     %nms = {'esi017noQd_C_finerConc','esi017noQd_01_finerConc','esi017noQd_03_finerConc','esi017noQd_1_finerConc','esi017noQd_3_finerConc','esi017noQd_10_finerConc','esi017noQd_30_finerConc'};%
nms2 = {'t'};    
dapimax =5000;   %now used as the area thresh in colony analysis; dapimax is set to max 60000 within the generalized mean function

dir = '.';
usemeandapi =[];
flag = 1;
index1 = [8 5];
param1 = 'Sox2';
ucol = 7; % look at distributions for the ucolonies of size up to ucol
close all
[rawdata1] =  Hist_vs_ColSize(nms,nms2,dir,index1,param1,dapimax,usemeandapi,flag,ucol);

%[0.5 0.4 0.1 0.5 0.45 0.15 0.2]