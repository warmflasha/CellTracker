%%
%acoords = olympusToMM(MMdirec,filenames,chan);

 MMdirec1 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-08-26-SparseCellsibidi/control');
 MMdirec2 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-08-26-SparseCellsibidi/10ngmlBMP4');

 chan = {'DAPI','GFP','CY5'};%  pERK, nanog

 filenames1 = 'control.btf';
 filenames2 = '10ngmlBMP4.btf';
 

 
 acoords1 = olympusToMMbtf(MMdirec1,filenames1,chan);
 acoords2 = olympusToMMbtf(MMdirec2,filenames2,chan);

 disp('Succesfully split all files for sparse cells ibidi');




