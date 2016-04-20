%%
%acoords = olympusToMM(MMdirec,filenames,chan);
% CY5 - Oct4; RFP = Bra; GFP = pERK 

MMdirec1 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-04-18-IbidiSlidesRepresentativeImg/C_for_FGFi_24hrXP');
MMdirec2 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-04-18-IbidiSlidesRepresentativeImg/C_for_FGFRi_24hrXP');
MMdirec3 = ('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-04-18-IbidiSlidesRepresentativeImg/FGFi_24hrXP');
MMdirec4 = ('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-04-18-IbidiSlidesRepresentativeImg/FGFRi_24hrXP');

chan = {'DAPI','RFP'};

% cell array, if extract from the regular  .tif
filenames1 = {'ControlforFGFi_24hr_pERKxp_C0001.tif','ControlforFGFi_24hr_pERKxp_C0002.tif'};
filenames2 = {'CforFGFRi_24hr_pERKxp_C0001.tif','CforFGFRi_24hr_pERKxp_C0002.tif'};
filenames3 = {'FGFi_24hr_pERKxp_C0001.tif','FGFi_24hr_pERKxp_C0002.tif'};
filenames4 = {'FGFRi_24hr_pERKxp_C0001.tif','FGFRi_24hr_pERKxp_C0002.tif'};

%  filenames1 = 'Control.btf';
%  filenames2 = 'BMPi.btf';
%  filenames3 = 'FGFreceptor_i.btf';% this is not BMPi, but BMP4
%olympusToMMbtf



acoords1 = olympusToMM(MMdirec1,filenames1,chan);
acoords2 = olympusToMM(MMdirec2,filenames2,chan);
acoords3 = olympusToMM(MMdirec3,filenames3,chan);
acoords4 = olympusToMM(MMdirec4,filenames4,chan);

disp('Succesfully split all files');
