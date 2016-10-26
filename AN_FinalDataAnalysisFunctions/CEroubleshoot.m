%%

ff = dir('.');
k = 25;
if ~isdir(ff(k).name)
matfile = ff(k).name;
mkFullCytooPlotPeaks('PluriNtwInh_Furin(nodal_Inh).mat');
disp(matfile)
end

%% get the raw image files from .btf or .tif

MMdirec1 = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/13_20160222-PaperFigures_DATA/CEtroubleshooting/FGFi_inCEpluriMEKi';
chan = {'DAPI'};
filenames1 = {'FGFi_C0001.tif'};
flag = 0;% flag = 1 for .btf; flag = 0 or [] for .tif

[acoords]=templateSplitOlympData(MMdirec1,chan,filenames1,flag);



%% plot montage with colonies and colony sizes labeled

dir ='/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/13_20160222-PaperFigures_DATA/CEtroubleshooting/FGFi_inCEpluriMEKi';%'/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-10-03-densityR/62um';%'/Volumes/data2/Anastasiia/totestClonyGrouping/torun';
%dir = '/Volumes/data2/Anastasiia/2016-04-06-Inhibitors(Bi_FGFRi)/FGFRi_extracted';
matfile = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/13_20160222-PaperFigures_DATA/CEtroubleshooting/worked/FGFinCE_FGFi160.mat';
chan = 'DAPI';
scale = 0.2;
N =8;
labelMontageColonies(dir,matfile,chan,scale,N)
%% label image numbers on the montage
%dir = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/06-05-2016-fixedGFPs4cells_troubleshooting/GFP-Smad4cellsTroubleshootandSox2stain/gfps4_june3';
dir = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-10-19-R2otherMEKiandLEFTY/R2control';
matfile = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/13_20160222-PaperFigures_DATA/CEtroubleshooting/worked/GFPs4cells_failedimagingJune3.mat';
chan = 'DAPI';
scale = 0.2;


labelStitchPreviewMM(dir,matfile,chan,scale)
%% plot the usual analysis (mean vs N)
nms = {'FGFinCE_Control','FGFinCE_FGFi160'};    % ,'Lefty_R','otherMEKi_R'  dapi gfp(sox2) rfp(nanog)
nms2 = {'C','PD98059'};%  ,'Lefty','MEKi*'  nanog(555) peaks{}(:,8), pERK(488) peaks{}(:,6)
%  nms = {'ControluCol_pAkt','MEKi_uCol_pAkt'};    % ,'Lefty_R','otherMEKi_R'  dapi gfp(sox2) rfp(nanog)
%  nms2 = {'C','MEKi'};%  ,'Lefty','MEKi*'  nanog(555) peaks{}(:,8), pERK(488) peaks{}(:,6)
dapimax =2000;%now used as the area thresh in colony analysis; dapimax is set to max 60000 within the generalized mean function
chanmax = 60000;
dir = '.';
usemeandapi =[];
flag1 = 1;
[mediaonly,~,~,~,~]= plotallanalysisAN(3,nms,nms2,dir,[],[],[8 5],[8 6],'Sox2','Dapi',0,1,dapimax,chanmax,usemeandapi,flag1);  
figure(6), xlim([0 7]);ylim([1 4.8])

%% rerun colony grouping
direc = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/13_20160222-PaperFigures_DATA/CEtroubleshooting/FGFi_inCEpluriMEKi';%'/Volumes/data2/Anastasiia/totestClonyGrouping/torun';
paramfile = '/Users/warmflashlab/CellTracker/paramFiles/setUserParamAN20X_uCOL_mek.m';
run(paramfile);

ff = readMMdirectory(direc);
%for k=1:size(ff,1)
  % if isdir(ff(k).name) == 0
   %outfile = ff(k).name;
   outfile = 'FGFinCE_FGFi.mat';
   
   load([direc filesep outfile],'bIms','nIms','dims');
   [colonies, peaks]=peaksToColonies([direc filesep outfile]);


     plate1=plate(colonies,dims,direc,ff.chan,bIms,nIms, outfile);
%
     plate1.mm = 1;
     plate1.si = size(bIms{1});
    save([direc filesep outfile],'plate1','peaks','-append');
    disp('done');
   % save([direc filesep outfile],'colonies','peaks','-append');
 %  end
%end





