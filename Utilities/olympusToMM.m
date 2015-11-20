function files = olympusToMM(MMdirec,filenames,chan)
files = mkMMFileStruct(MMdirec,chan);

h = iminfo(filenames{1});




function files = mkMMFileStruct(direc,chan)

files.direc = direc;
files.prefix = '1-'; 
%files.pos_x = unique(pos_x);
%files.pos_y = unique(pos_y);
files.chan = chan;
files.subprefix = 'img';

