function [ttuse ppuse lig]=mkCCCMovie(direc,filekeyword,matfile,imcol,outfile,cellnum)

ytick1=0.6:0.2:1.6;
ytick2=0:0.5:1;

%[~, ff]=folderFilesFromKeyword(direc,filekeyword);


load(matfile,'pictimes','cells2');
dd=cells2(cellnum).data;

ttuse=pictimes;
ppuse=dd(:,9)./dd(:,10);

px=dd(:,1);
py=dd(:,2);
maxx = max(px);
minx = min(px);
maxy = max(py);
miny = min(py);
xyrange = [minx-100 maxx+100 miny-100 maxy+100];
nframes=min(length(ppuse),length(pictimes));
nframes=nframes;
writerObj=VideoWriter(outfile);
writerObj.FrameRate=nframes/10; % movie will be 10 sec long
open(writerObj);

fi=figure;
set(fi,'Color','k');
for ii=1:nframes
    img=imread([direc filesep 'frame_z3_' int2str(ii) '_f1.jpg']);
    im2show=img;
    if ii==1
        imL=stretchlim(img,[0.05 0.99]);
    end
    im2show=imadjust(im2show,imL);
    im2show=cat(3,imcol(1)*im2show,imcol(2)*im2show,imcol(3)*im2show);
    
    subplot(1,2,1);
    imshow(im2show); axis(xyrange); hold on;
    plot(dd(ii,1),dd(ii,2),'r.','MarkerSize',16);
    
    
    subplot(1,2,2); cla; hold on;
    xtickuse=0:1:5;

    plot(ttuse(1:ii),ppuse(1:ii),'Color',imcol,'LineWidth',2);
    maxy=max(ppuse); miny=min(ppuse);
    
    set(gca,'Color','k','YColor',imcol,'XColor','w','YTick',ytick1,'XTick',xtickuse,'FontSize',14);
    xlim([0 max(ttuse)]);

    ylim([min(ppuse)-0.1 max(ppuse)+0.1]);
    frm=getframe(fi);
    writeVideo(writerObj,frm);
end

close(writerObj);
