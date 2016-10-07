function labelMontageColonies(dir,matfile,chan,scale,N)
% function to plot the montage of the chip, with the colonies of size N on it 

load(matfile,'peaks','plate1','acoords',',bIms','nIms');
files = readMMdirectory(dir);

if ~exist('xrange','var') || isempty(xrange)
    xrange = files.pos_x;
end

if ~exist('yrange','var') || isempty(yrange)
    yrange = files.pos_y;
end
if ~exist('chan','var') || isempty(chan)
    chan='DAPI';
end

if ~exist('scale','var') || isempty(scale)
    scale = 0.2;
end
fi = StitchPreviewMM(files,acoords);
figure(1), imshow(fi,[]),hold on
% incorporate colony size and colorcode here
colormap = prism;
for i =1:N
     dat = mkFullCytooPlotSelectCol(matfile,0,1,1,i);
 
 figure(1), hold on
 plot(scale*nonzeros(dat(:,2)),scale*nonzeros(dat(:,1)),'*');

end



end



