%split btf files

 MMdirec1 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-09-13-uColGATA3Cdx2/controlGATA3cdx2');
 MMdirec2 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-09-13-uColGATA3Cdx2/10ngmlBMP4gata3cdx2');

 
 chan1 = {'DAPI','GFP','CY5'};%  488 GATA3 647 - cdx2

 filenames1 = 'Control_gata3Cdx2.btf';
 filenames2 = '10ngmlBMP4_gata3Cdx2.btf';

 acoords1 = olympusToMMbtf(MMdirec1,filenames1,chan1);
 acoords2 = olympusToMMbtf(MMdirec2,filenames2,chan1);
 
 
 
 disp('Succesfully split all files for gata3 exper');


save('c','acoords1');
save('10ngmlbmp4','acoords2');





