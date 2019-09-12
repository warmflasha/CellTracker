function max_img =andorMaxIntensityBF(files,pos,time,chan)
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

if isempty(files.z)
    filename = getAndorFileName(files,pos,0,0,chan);
    reader = bfGetReader(filename);
    if time > reader.getSizeT
        timefile = floor(time/reader.getSizeT);
        timeInFile = time-reader.getSizeT*timefile;
        filename = getAndorFileName(files,pos,timefile,0,chan+1);
        reader = bfGetReader(filename);
    else
        timeInFile = time;
    end
    max_img = bfMaxIntensity(reader,timeInFile+1,chan);
    reader.close;
    
end

for ii=1:length(files.z)
    filename = getAndorFileName(files,pos,0,files.z(ii),chan);
    reader = bfGetReader(filename);
    if time > reader.getSizeT
        timefile = floor(time/reader.getSizeT);
        timeInFile = time -reader.getSizeT*timefile;
        filename = getAndorFileName(files,pos,timefile,files.z(ii),chan);
        reader = bfGetReader(filename);
    else
        timeInFile = time;
    end
    img_now = bfMaxIntensity(reader,timeInFile+1,1);
    if ii==1
        max_img=img_now;
    else
        max_img=max(img_now,max_img);
    end
    reader.close;
end
