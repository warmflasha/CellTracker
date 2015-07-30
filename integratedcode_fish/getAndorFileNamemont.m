function filename = getAndorFileNamemont(files,pos,time,z,w)
% filename = getAndorFileName(files,pos,time,z,w)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% returns file name from a image from the Andor iQ software
% inputs: -files: file structure returned by readAndorDirectory
%         -pos: position number
%         -time: time number
%         -z: z-stack number
%         -w: channel number
% note: -all numberings begin from 0 with andor software
%       -empty array [] can be input for 
%           any item that is not present in the dataset 
%
% see also: readAndorDirectory, andorMaxIntensity


filename = files.prefix; 


for ii=1:length(files.ordering)
    switch files.ordering(ii)
        case 'm'
            num = int2str(pos);
        case 't'
            num=int2str(time);
        case 'z'
            num = int2str(z);
        case 'w'
            num = int2str(w);
    end
    
    while length(num) < 4
        num = ['0' num];
    end
    str1 = ['_' files.ordering(ii) num];
    filename = [filename str1];
end

filename = [files.direc filesep filename '.tif'];