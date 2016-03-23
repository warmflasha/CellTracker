%%
%acoords = olympusToMM(MMdirec,filenames,chan);
% CY5 - Oct4; RFP = Bra; GFP = pERK 

MMdirec1 = ('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-03-18-ABtest/ABtest_control_extracted');
MMdirec2 = ('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-03-18-ABtest/ABtest_FGFi_extracted');
MMdirec3 = ('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-03-07-Inhibitors/extracted_FGFi');

chan = {'DAPI','GFP','RFP','CY5'};


filenames1 = {'Control_C0001.tif','Control_C0002.tif','Control_C0003.tif','Control_C0004.tif'};
filenames2 = {'FGFi_C0001.tif','FGFi_C0002.tif','FGFi_C0003.tif','FGFi_C0004.tif'};

filenames3 = 'FGFi.btf';


acoords3 = olympusToMMbtf(MMdirec3,filenames3,chan);

disp('Succesfully split all files');
