function filename=mkMMfilename(files,pos_x,pos_y,z,t,chan)

if ~exist('chan','var')
    chan = files.chan;
end

if ~exist('z','var')
    z=[];
end

if ~exist('t','var')
    t=[];
end

if ~exist('pos_x','var')
    pos_x=[];
end

if ~exist('pos_y','var')
    pos_y=[];
end

if isinteger(chan)
    chan = files.chan(chan);
end

pos_x=int2str(pos_x);
while length(pos_x) < 3
    pos_x = ['0' pos_x];
end

pos_y=int2str(pos_y);
while length(pos_y) < 3
    pos_y = ['0' pos_y];
end

t=int2str(t);
while length(t) < 9
    t = ['0' t];
end

z=int2str(z);
while length(z) < 3
    z = ['0' z];
end

direc = [files.direc filesep files.prefix 'Pos_' pos_x '_' pos_y];

for ii=1:length(chan)
    filename{ii} = [direc filesep files.subprefix '_' t '_' chan{ii} '_' z '.tif'];
end