function filename=mkMMfilenameOneCoord(files,pos_x,z,t,chan)

if ~exist('chan','var')
    chan = 1;
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

if ~iscell(chan)
    chan = files.chan(chan);
end

pos_x=int2str(pos_x);

t=int2str(t);
while length(t) < 9
    t = ['0' t];
end

z=int2str(z);
while length(z) < 3
    z = ['0' z];
end

direc = [files.direc filesep 'Pos' pos_x];

for ii=1:length(chan)
    filename{ii} = [direc filesep files.subprefix '_' t '_' chan{ii} '_' z '.tif'];
end