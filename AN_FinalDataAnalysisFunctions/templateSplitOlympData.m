%%
%acoords = olympusToMM(MMdirec,filenames,chan);
% CY5 - Oct4; RFP = Bra; GFP = pERK 

MMdirec1 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-03-23-FGFinCEdiff/Control_pluri_extracted');
MMdirec2 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-03-23-FGFinCEdiff/Control_diff3ngml_extracted');
MMdirec3 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-03-23-FGFinCEdiff/3ngmlBMP4withFGFi_extracted');
 
 
chan = {'DAPI','GFP','RFP','CY5'};

% cell array, if extract from the regulat .tif
% filenames1 = {'Control_C0001.tif','Control_C0002.tif','Control_C0003.tif','Control_C0004.tif'};
% filenames2 = {'FGFi_C0001.tif','FGFi_C0002.tif','FGFi_C0003.tif','FGFi_C0004.tif'};

filenames1 = 'Control_pluri.btf';
filenames2 = 'Control_diff3ngml.btf';
filenames3 = 'BMPi_FGFi.btf';% this is not BMPi, but BMP4

acoords1 = olympusToMMbtf(MMdirec1,filenames1,chan);
acoords2 = olympusToMMbtf(MMdirec2,filenames2,chan);
acoords3 = olympusToMMbtf(MMdirec3,filenames3,chan);

disp('Succesfully split all files');
