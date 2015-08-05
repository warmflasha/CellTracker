function max_img =andorMaxIntensity(files,pos,time,chan)
 % max_img =andorMaxIntensity(files,pos,time,chan)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % returns the maximum intensity image from an Andor iQ3 directory
 %
 % inputs: -files: file structure returned by readAndorDirectory
%         -pos: position number
%         -time: time number
%         -chan: channel number
% note: all numberings begin from 0 with andor software
%       -empty array [] can be input for 
%           any item that is not present in the dataset 
%
% see also: readAndorDirectory, getAndorFileName
 
    for ii=1:length(files.z)
        filename = getAndorFileName(files,pos,time,files.z(ii),chan);
        img_now = imread(filename);
        if ii==1
            max_img=img_now;
        else
            max_img=max(img_now,max_img);
        end
    end