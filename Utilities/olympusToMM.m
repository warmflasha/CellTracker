function files = olympusToMM(MMdirec,filenames,chan,imsize)

if ~exist('imsize','var')
    imsize = [2048 2048];
end

files = mkMMFileStruct(MMdirec,chan);
h = imfinfo(filenames{1});
n_width = h.Width/imsize(1);
n_height = h.Height/imsize(2);

if ~isinteger(n_width)
    n_width = floor(n_width) + 1;
end
if ~isinteger(n_height)
    n_height = floor(n_height)+1;
end




function files = mkMMFileStruct(direc,chan)

files.direc = direc;
files.prefix = '1-'; 
%files.pos_x = unique(pos_x);
%files.pos_y = unique(pos_y);
files.chan = chan;
files.subprefix = 'img';

