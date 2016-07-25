%%
% run the data analysis overnight
% 2 ibidi wells with sox2 and cdx2 stains
% control and MEKi42hr
runFullTileMM('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-07-15-pAkt_DYN(Gabby)pAktNanogSmad2/control_sox2cdx2','Control_med_chSox2Cdx2.mat','setUserParamAN20X');
runFullTileMM('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-07-15-pAkt_DYN(Gabby)pAktNanogSmad2/meki42hr_sox2cdx2','42hrMEKi_Sox2Cdx2.mat','setUserParamAN20X');

% pERK ibidi same params as uCOl chips (same day imaging)
runFullTileMM('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-07-21-uColvsIbidi_full/control_ibidi_medchange','C_medchange_ibidi_sameImgaqsettings.mat','setUserParamAN20X');
runFullTileMM('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-07-21-uColvsIbidi_full/ibidi_42hrMEKi','MEKi42hr_ibidi_sameImgaqsettings.mat','setUserParamAN20X');

% 
% pERK uCol same params ibidi (same day imaging)
runFullTileMM('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-07-21-uColvsIbidi_full/control_uCol','C_uCol_sameImgaqsettings.mat','setUserParamAN20X_uCOL');
runFullTileMM('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-07-21-uColvsIbidi_full/uCol_42hrMEKi','MEKi42hr_uCol_sameImgaqsettings.mat','setUserParamAN20X_uCOL');
 
disp('successfully ran all 20X segmentation')

DirInfo_TrackMicroCol
