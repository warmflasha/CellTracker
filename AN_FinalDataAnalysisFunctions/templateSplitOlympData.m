
function [acoords1]=templateSplitOlympData(MMdirec1,chan,filenames1,flag)

%split btf files

 %MMdirec1 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/Outall_files_PluriNtwInh/C_RonlyDapiSox2');
%  MMdirec2 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-10-04-RotherMEKiLefty_Sox2Nanog/otherMEKi_R');
%  MMdirec3 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/2_NO_QUADRANTS_goodData(esi017Cells)/2016-10-04-RotherMEKiLefty_Sox2Nanog/Lefty_R');

 

 
 %chan = {'DAPI','GFP'};% 

 % filenames1 = {'Control(R)_C0001.tif','Control(R)_C0002.tif'};
%  filenames2 = 'MEKiother.btf';
%  filenames3 = 'Lefty.btf';
 

if flag == 1
    acoords1 = olympusToMMbtf(MMdirec1,filenames1,chan);
end
if flag == 0 || isempty(flag)
    acoords1 = olympusToMM(MMdirec1,filenames1,chan);
    
end

 %save('Conlyaccords','acoords1');
 
% disp('Succesfully split all files for meki control');
end
 







