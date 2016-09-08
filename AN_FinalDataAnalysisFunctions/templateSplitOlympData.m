%%
%acoords = olympusToMM(MMdirec,filenames,chan);
% 
%  MMdirec1 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-09-07-DensityEffects_uCol/pluri_30um1');
%  MMdirec2 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-09-07-DensityEffects_uCol/pluri_62um1');
%  MMdirec3 = ('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-09-07-DensityEffects_uCol/diff_30um');
%  MMdirec4 = ('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-09-07-DensityEffects_uCol/diff_62um');
% 
%  chan1 = {'DAPI','GFP'};%  
%  chan2 = {'DAPI','CY5'};% 
%  
% 
%  filenames1 = 'NoQdrRchip_C_30umPatt.btf';
%  filenames2 = 'NoQdrRchip_C_62umPatt.btf';
%  filenames3 = 'NoQdrRchip_10ngml_30umPattCdx2.btf';
%  filenames4 = 'NoQdrRchip_10ngml_62umPattCdx2.btf';
% 
%  
%  acoords1 = olympusToMMbtf(MMdirec1,filenames1,chan1);
%  acoords2 = olympusToMMbtf(MMdirec2,filenames2,chan1);
%  acoords3 = olympusToMMbtf(MMdirec3,filenames3,chan2);
%  acoords4 = olympusToMMbtf(MMdirec4,filenames4,chan2);
%  
%  disp('Succesfully split all files for density exper');
% 
% 
% save('pluri30um','acoords1');
% save('pluri62um','acoords2');
% save('diff30um','acoords3');
% save('diff62um','acoords4');

%%
%split the other MEKi (THU)

 MMdirec1 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-09-06-otherMEKi_uCol/otherMEKi_C');
 MMdirec2 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-09-06-otherMEKi_uCol/otherMEKi_1uM');
 chan1 = {'DAPI','GFP','RFP'};%  sox2, nanog

 filenames1 = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-09-06-otherMEKi_uCol/control_otherMEKi.btf';
 filenames2 = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-09-06-otherMEKi_uCol/uCol_1uMotherMEKi.btf';
 
 acoords1 = olympusToMMbtf(MMdirec1,filenames1,chan1);
 acoords2 = olympusToMMbtf(MMdirec2,filenames2,chan1);
 
 disp('Succesfully split all files for other MEKi exper');


save('control_acc','acoords1');
save('1uMmeki_acc','acoords2');




