function addClocktoMovie(infile,outfile)

%read the movie
rO=VideoReader(infile);
vF=read(rO);
si=size(vF);

%make the output file
writerObj=VideoWriter(outfile);
writerObj.FrameRate=5;
open(writerObj);

%setup the figure
fi=figure;
si=si/2;
set(fi,'Position',[100 100 512*1.5 512])
set(fi,'Color','k');
subplot(1,2,2); cc=scottsclock; cc.updateClock([1 1 1 12 0 0]);

%loop through movie frames, updating the clock
for ii=1:31
    tt=vF(:,:,:,ii);
    subplot(1,2,1); imshow(tt);
    h=get(fi,'Children');
    h = get(fi,'Children');
    set(h(1),'Position',[0.1 0.1 0.6 0.95 ]);
    set(h(2),'Position',[0.75 2/3 0.23 0.23]);
    cc.updateClock([1 1 1 12 4*ii 0]);
    frm=getframe(fi);
    writeVideo(writerObj,frm);
end

close(writerObj);