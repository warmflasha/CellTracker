nms = {'esi017noQd_C_finerConc'};     % R2control160','R2otherMEK160'
nms2 = {'c'};    
dapimax =5000;   %now used as the area thresh in colony analysis; dapimax is set to max 60000 within the generalized mean function

dir = '.';
usemeandapi =[];
flag = 1;
index1 = [6 5];
param1 = 'Cdx2';
ucol = 7; % look at distributions for the ucolonies of size up to ucol

[rawdata1] =  Hist_vs_ColSize(nms,nms2,dir,index1,param1,dapimax,usemeandapi,flag,ucol);