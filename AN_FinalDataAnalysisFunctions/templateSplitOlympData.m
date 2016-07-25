%%
%acoords = olympusToMM(MMdirec,filenames,chan);
% CY5 - Oct4; RFP = Bra; GFP = pERK 
% pAktDyn   Gabby ibidi
 MMdirec1 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-07-21-uColvsIbidi_full/control_ibidi_medchange');
 MMdirec2 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-07-21-uColvsIbidi_full/control_uCol');
 MMdirec3 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-07-21-uColvsIbidi_full/ibidi_42hrMEKi');
 MMdirec4 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-07-21-uColvsIbidi_full/uCol_42hrMEKi');
% MMdirec5 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-07-15-pAkt_DYN(Gabby)pAktNanogSmad2/30hr_pAktdyn');
% MMdirec6 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-07-15-pAkt_DYN(Gabby)pAktNanogSmad2/42hr_pAktdyn');

chan = {'DAPI','GFP','RFP'};%  pRK and Nanog (rfp)

 filenames1 = {'control_ibidi_C0001.tif','control_ibidi_C0002.tif','control_ibidi_C0003.tif'};
 filenames2 = {'uCol_control_nomedchange1hr_C0001.tif','uCol_control_nomedchange1hr_C0002.tif','uCol_control_nomedchange1hr_C0003.tif'};
 filenames3 = {'ibidi_42hrMEKi_C0001.tif','ibidi_42hrMEKi_C0002.tif','ibidi_42hrMEKi_C0003.tif'};
 filenames4 = {'uCol_42hrMEKi_C0001.tif','uCol_42hrMEKi_C0002.tif','uCol_42hrMEKi_C0003.tif'};
% filenames5 = {'MEKi_30hr_pAktstain_C0001.tif','MEKi_30hr_pAktstain_C0002.tif','MEKi_30hr_pAktstain_C0003.tif','MEKi_30hr_pAktstain_C0004.tif'};
% filenames6 = {'MEKi_42hr_pAktstain_C0001.tif','MEKi_42hr_pAktstain_C0002.tif','MEKi_42hr_pAktstain_C0003.tif','MEKi_42hr_pAktstain_C0004.tif'};

 acoords1 = olympusToMM(MMdirec1,filenames1,chan);
 acoords2 = olympusToMM(MMdirec2,filenames2,chan);
 acoords3 = olympusToMM(MMdirec3,filenames3,chan);
 acoords4 = olympusToMM(MMdirec4,filenames4,chan);
% acoords5 = olympusToMM(MMdirec5,filenames5,chan);
% acoords6 = olympusToMM(MMdirec6,filenames6,chan);

disp('Succesfully split all files for ibidi pAkt');

%%
% tiling uCol imaged all chip
MMdirec7 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-07-15-uCol_gfpSmad4Cdx2_24hrin10ngmlBMP4(tilingLiveCell)/gfpS2_aftTile10ngmlBMP4_24hr');
chan2 = {'DAPI','GFP','CY5'}; % here only did gfp (smad4) and CY5 (cdx2)

filenames7 = 'gfpS4_afttilinglivec10ngmlbmp4.btf';

acoords7 = olympusToMMbtf(MMdirec7,filenames7,chan2);

disp('Succesfully split all files GFPs4 cells tiling chip');
%%
% uCol control and MEKi chip, pERK, Nanog, Smad2

MMdirec8 = ('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-07-16-uCol_MEKi10uM_pERKNanogSmad2/control_pERKnanogSmad2');
MMdirec9 = ('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-07-16-uCol_MEKi10uM_pERKNanogSmad2/MEKi_pERKnanogSmad2');

chan3 = {'DAPI','GFP','RFP','CY5'}; % pERK, Nanog, Smad2

% cell array, if extract from the regular  .tif
%filenames1 = 'failedImgGFPS4_sox2_647.btf';
%filenames2 = 'Jan8livecell_10ngml43hr_sox2_647.btf';
%filenames3 = 'Lefty500ngml.btf';

filenames8 = 'Control_pERKNanogSmad2.btf';
filenames9 = 'MEKi10uM_pERKNanogSmad2.btf';

%   filenames1 = 'Control_FucciG1.btf';
%   filenames2 = 'BMP4_FucciG1.btf';
%  filenames3 = 'FGFreceptor_i.btf';% this is not BMPi, but BMP4
%olympusToMMbtf

acoords8 = olympusToMMbtf(MMdirec8,filenames8,chan3);
acoords9 = olympusToMMbtf(MMdirec9,filenames9,chan3);

disp('Succesfully split all files for th MEKi repeat exper ( pERK, Smad2, Nanog)');
%acoords3 = olympusToMMbtf(MMdirec3,filenames3,chan);

%acoords4 = olympusToMM(MMdirec4,filenames4,chan);


