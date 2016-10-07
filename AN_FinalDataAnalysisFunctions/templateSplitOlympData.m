%split btf files

 MMdirec1 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/Outall_files_PluriNtwInh/C_RonlyDapiSox2');
%  MMdirec2 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-10-04-RotherMEKiLefty_Sox2Nanog/otherMEKi_R');
%  MMdirec3 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-10-04-RotherMEKiLefty_Sox2Nanog/Lefty_R');

 

 
 chan = {'DAPI','GFP'};% 

 filenames1 = {'Control(R)_C0001.tif','Control(R)_C0002.tif'};
%  filenames2 = 'MEKiother.btf';
%  filenames3 = 'Lefty.btf';
 


 acoords1 = olympusToMM(MMdirec1,filenames1,chan);
%  acoords2 = olympusToMMbtf(MMdirec2,filenames2,chan);
%  acoords3 = olympusToMMbtf(MMdirec3,filenames3,chan);


 save('Conlyaccords','acoords1');
 
 disp('Succesfully split all files for meki control');






