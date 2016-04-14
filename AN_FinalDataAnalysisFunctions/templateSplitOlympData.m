%%
%acoords = olympusToMM(MMdirec,filenames,chan);
% CY5 - Oct4; RFP = Bra; GFP = pERK 

MMdirec1 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-04-06-MixExperiment/esiPluri_H2BDiff_extracted');
MMdirec2 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-04-06-MixExperiment/esiPluri_H2BPluri_extracted');


chan = {'DAPI','GFP','RFP','CY5'};

% cell array, if extract from the regular  .tif
% filenames1 = {'FGFi_1to400ab_C0001.tif','FGFi_1to400ab_C0002.tif'};
% filenames2 = {'FGFi_1to100ab_C0001.tif','FGFi_1to100ab_C0002.tif'};
% filenames3 = {'C_1to400ab_C0001.tif','C_1to400ab_C0002.tif'};
% filenames4 = {'C_1to100ab_C0001.tif','C_1to100ab_C0002.tif'};

 filenames1 = 'esiPluri_H2BDiff.btf';
 filenames2 = 'esiPluri_H2BPluri.btf';
% filenames3 = 'BMPi_FGFi.btf';% this is not BMPi, but BMP4

acoords1 = olympusToMMbtf(MMdirec1,filenames1,chan);
acoords2 = olympusToMMbtf(MMdirec2,filenames2,chan);


disp('Succesfully split all files');
