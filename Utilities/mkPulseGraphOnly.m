function mkPulseGraphOnly(direc,condnum,matfilerange,pulsetime,pulseheight,imcol,outfile)

for ii=1:matfilerange
    [pp(ii,:) tt(ii,:)]=peaksAverage([direc filesep 'S' int2str(condnum) 's' ...
        int2str(ii) 'out.mat'],[6 7]);
end

ppuse=mean(pp); ttuse=mean(tt);
nframes=length(pp);

writerObj=VideoWriter(outfile);
writerObj.FrameRate=5;
open(writerObj);

lig=zeros(nframes,1);
lig(pulsetime:end)=pulseheight;
fi=figure;
set(fi,'Color','k');
% define the figure size
%set(fi,'Position',[100    100    rect(3)*3    rect(4) ])

for ii=1:nframes
    
    
    [AX H1 H2]=plotyy(ttuse(1:ii),ppuse(1:ii),ttuse(1:ii),lig(1:ii));
    ylim(AX(1),[min(ppuse)-0.1 max(ppuse)+0.1]);
    ylim(AX(2),[-0.05 pulseheight+0.05]);
    set(AX(1),'Color','k','YColor',imcol,'XColor','w','YTick',[1 1.5 2 2.5 3],'XTick',[0 5 10 15],'FontSize',14);
    set(AX(2),'YColor','r','YTick',[0 0.5 1],'Xcolor','w','XTick',[0 5 10 15],'FontSize',14);
    set(H1,'Color',imcol,'LineWidth',4);
    set(H2,'Color','r','LineWidth',4);
    xlim(AX(1),[0 max(ttuse)]);
    xlim(AX(2),[0 max(ttuse)]);
    
    set(get(AX(2),'Xlabel'),'String','time (hrs)','FontSize',14,'FontName','Helvetica')
    set(get(AX(1),'Ylabel'),'String','Smad 4 nuc/cyto','FontSize',14,'FontName','Helvetica')
    set(get(AX(2),'Ylabel'),'String','[TGF-\beta1] (ng/ml)','FontSize',14,'FontName','Helvetica')
    
    %  resize stuff   
     h = get(fi,'Children');
%     set(h(3),'Position',[0    0    1/3    1 ]);
%     set(h(1),'Position',[0.42    0.18    0.5    0.78 ]);
    
%     put the smad time course on top
    uistack(h(2),'top')
    set(h(2),'Color','none','Box','off')

    
    frm=getframe(fi);
    writeVideo(writerObj,frm);
end

close(writerObj);
