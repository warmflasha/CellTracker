function img = maxIntensityLSMMontage(directory,position,tt)

posstr = '0000';
posstrtmp = int2str(position);
for ii = 1:length(posstrtmp)
    posstr(end-ii+1)=posstrtmp(end-ii+1);
end

if ~exist('tt','var')
    timestr = '01';
else
    timestr = int2str(tt);
    if length(timestr) < 2
        timestr = ['0' timestr];
    end
end

oiffile = [directory filesep 'Track' posstr filesep 'Image' posstr '_' timestr '.oif'];

reader = bfGetReader(oiffile);

nC = reader.getSizeC;
sizeX = reader.getSizeX;
sizeY = reader.getSizeY;

img = zeros(sizeX,sizeY,nC);

for ii = 1:nC
    img(:,:,ii) = bfMaxIntensity(reader,1,ii);
end
    

