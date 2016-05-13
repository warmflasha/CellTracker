%%
%acoords = olympusToMM(MMdirec,filenames,chan);
% CY5 - Oct4; RFP = Bra; GFP = pERK 

MMdirec1 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-04-27-CMvsMtesrFGFigraded/CM/cm_control');
MMdirec2 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-04-27-CMvsMtesrFGFigraded/CM/cm_FGFi10uM');
MMdirec3 = ('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-04-27-CMvsMtesrFGFigraded/CM/cm_FGFi30uM');
MMdirec4 = ('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-04-27-CMvsMtesrFGFigraded/CM/cm_FGFRi200nM');


chan = {'DAPI','GFP','RFP'};

% cell array, if extract from the regular  .tif
filenames1 = {'cm_control6hr_C0001.tif','cm_control6hr_C0002.tif','cm_control6hr_C0003.tif'};
filenames2 = {'cm_FGFi10uM6hr_C0001.tif','cm_FGFi10uM6hr_C0002.tif','cm_FGFi10uM6hr_C0003.tif'};
filenames3 = {'cm_FGFi30uM6hr_C0001.tif','cm_FGFi30uM6hr_C0002.tif','cm_FGFi30uM6hr_C0003.tif'};
filenames4 = {'cm_FGFRi200nM6hr_C0001.tif','cm_FGFRi200nM6hr_C0002.tif','cm_FGFRi200nM6hr_C0003.tif'};


%  filenames1 = 'Control.btf';
%  filenames2 = 'BMPi.btf';
%  filenames3 = 'FGFreceptor_i.btf';% this is not BMPi, but BMP4
%olympusToMMbtf

acoords1 = olympusToMM(MMdirec1,filenames1,chan);
acoords2 = olympusToMM(MMdirec2,filenames2,chan);
acoords3 = olympusToMM(MMdirec3,filenames3,chan);
acoords4 = olympusToMM(MMdirec4,filenames4,chan);

disp('Succesfully split all files');
