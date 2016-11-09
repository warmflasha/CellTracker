nms = {'esi017noQd_03_finerConc'};    % ,'Lefty_R','otherMEKi_R'  dapi gfp(sox2) rfp(nanog)
nms2 = {'0.3'};%  ,'Lefty','MEKi*'  dapi gfp(6) rfp(8)
dapimax =5000;   %now used as the area thresh in colony analysis; dapimax is set to max 60000 within the generalized mean function

dir = '.';
usemeandapi =[];
flag = 1;
index1 = [8 5];
param1 = 'Sox2';
ucol = 8; % look at distributions for the ucolonies of size up to ucol

[rawdata1] =  Hist_vs_ColSize(nms,nms2,dir,index1,param1,dapimax,usemeandapi,flag,ucol);