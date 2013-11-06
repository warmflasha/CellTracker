function mkManyPulseMovie(direc,filekeyword,matfile,pulsetime,pulseheight)

[~, ff]=folderFilesFromKeyword(direc,filekeyword);

[pp tt]=peaksAverage([direc filesep matfile],[6 7]);

nframes=min(length(pp),length(ff));

writerObj=VideoWriter('Step.avi');
writerObj.FrameRate=5;
open(writerObj);

lig=zeros(nframes,1);
lig(pulsetime:end)=pulseheight;
rect=[100 100  200 400];
fi=figure;
set(fi,'Color','k');
for ii=1:nframes
    img=imread([direc filesep ff(ii).name]);
    im2show=imcrop(img,rect);
    zz=zeros(size(im2show));
    if ii==1
        imL=stretchlim(img,[0.05 0.99]);
    end
    im2show=imadjust(im2show,imL);
    subplot(1,2,1); 
    imshow(cat(3,zz,im2show,zz));
    
    subplot(1,2,2); 
    [AX H1 H2]=plotyy(tt(1:ii),pp(1:ii),tt(1:ii),lig(1:ii));
    ylim(AX(1),[min(pp)-0.1 max(pp)+0.1]);
    ylim(AX(2),[-0.05 pulseheight+0.05]);
    set(AX(1),'Color','k','YColor','g','YTick',[0.6 0.8 1 1.2 1.4],'FontSize',14);
    set(AX(2),'YColor','r','YTick',[0 0.5 1],'FontSize',14);
    set(H1,'Color','g','LineWidth',4); 
    set(H2,'Color','r','LineWidth',4);
    xlim(AX(1),[0 max(tt)]);     
    xlim(AX(2),[0 max(tt)]);
    frm=getframe(fig);
    writeVideo(writerObj,frm);
end

close(writerObj);
