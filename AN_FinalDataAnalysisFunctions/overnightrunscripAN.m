%%
% run the data analysis overnight
% 

% low  bmp pSmad1-Smad4 corr, use the empty eimage taken in each channel as
% the background (instead of calculating)

runFullTileMM('control_esionlyinMtsr','control_esionlyinMtsr.mat','setUserParamAN20X',1);
runFullTileMM('3dBMPsb_2dMtsr','3dBMPsb_2dMtsr.mat','setUserParamAN20X',1);


disp('done');



  
%% split the ibidi .btfs
flag = 1;
%MMdirec1 = '/Volumes/TOSHIBAexte/2017-08-02-predifferentiatedcellsControls_sorting/control_esionlyinMtsr';
MMdirec2 = '/Volumes/TOSHIBAexte/2017-08-02-predifferentiatedcellsControls_sorting/3dBMPsb_2dMtsr';
MMdirec3 = '/Volumes/TOSHIBAexte/2017-08-02-predifferentiatedcellsControls_sorting/4dBMPsb_2dMtsr';


fn= {'3dBMPSB_2daysMtesr_sox2cdx2nanogdapi.btf','4daysBMPSB_2daysMT.btf'};
chan = {'DAPI','GFP','RFP','CY5'};% 
mm = {MMdirec2,MMdirec3};
cfpCprediff = cell(1,size(mm,2));
for k=1:size(mm,2)
   cfpCprediff{k} = templateSplitOlympData(mm{k},chan,fn{k},flag);
end
disp('split and saved all');
save('cfpCprediff');

%% run colony grouping only 

outfile ='300ngmlWNT3a_uCol.mat'; 
direc = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2017-01-27-WNT3aDosesandActinuCol/300ngmlWNT3a_uCol';
direc2 = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2017-01-27-WNT3aDosesandActinuCol/outfiles_group130px';
paramfile=('/Users/warmflashlab/CellTracker/paramFiles/setUserParamAN20X_uCOL.m');
run(paramfile);
ff = readMMdirectory(direc);
load([direc filesep outfile],'bIms','nIms','dims');
    [colonies, peaks]=peaksToColonies([direc filesep outfile]);
    plate1=plate(colonies,dims,direc,ff.chan,bIms,nIms, outfile);

    plate1.mm = 1;
    plate1.si = size(bIms{1});
    save([direc2 filesep outfile],'plate1','peaks','-append');  
disp('done');
