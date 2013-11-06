function [ttuse ppuse lig]=mkCCCGraphOnly(matfile,imcol,outfile)

ytick1=0.6:0.2:1.6;
ytick2=0:0.5:1;

[ppuse ttuse]=peaksAverage(matfile,[6 7]);

nframes=length(ppuse);

writerObj=VideoWriter(outfile);
writerObj.FrameRate=nframes/15;
open(writerObj);

%use the feedings array to extract ligand time courses
load(matfile,'feedings');
lig=zeros(nframes,1);
ftimes=[feedings.time];
for ii=1:nframes
    tdiff=ttuse(ii)-ftimes;
    ind1=find(tdiff > 0,1,'last');
    if isempty(ind1)
        ind1=1;
    end
    kk=strfind(feedings(ind1).medianame,'tgf');
    if kk
        lig(ii)=str2double(feedings(ind1).medianame((kk+3):end));
    end
end

%set the rectangle
fi=figure;
set(fi,'Color','k');
for ii=1:nframes

    
    if max(ttuse) > 30
        xtickuse=0:10:max(ttuse);
    else
        xtickuse=0:5:max(ttuse);
    end
        
    [AX H1 H2]=plotyy(ttuse(1:ii),ppuse(1:ii),ttuse(1:ii),lig(1:ii));
    maxy=max(ppuse); miny=min(ppuse);
    
    set(AX(1),'Color','k','YColor',imcol,'XColor','w','YTick',ytick1,'XTick',xtickuse,'FontSize',14);
    set(AX(2),'YColor','r','YTick',ytick2,'Xcolor','w','XTick',xtickuse,'FontSize',14);
    set(H1,'Color',imcol,'LineWidth',4,'HandleVisibility','off');
    set(H2,'Color','r','LineWidth',2,'LineStyle','--','HandleVisibility','off');
    
    xlim(AX(1),[0 max(ttuse)]);
    xlim(AX(2),[0 max(ttuse)]);

    ylim(AX(1),[miny-0.1 maxy+0.1]);
    ylim(AX(2),[-0.05 max(lig)+0.05]);
    
    %     put titles to axis
    
    set(get(AX(2),'Xlabel'),'String','time (hrs)','FontSize',18,'FontName','Helvetica','FontWeight','Bold')
    set(get(AX(1),'Ylabel'),'String','Smad 4 nuc/cyto','FontSize',18,'FontName','Helvetica','FontWeight','Bold')
    set(get(AX(2),'Ylabel'),'String','[TGF-\beta1] (ng/ml)','FontSize',18,'FontName','Helvetica','FontWeight','Bold')
    
    %  resize stuff
    h = get(fi,'Children');
    %set(h(3),'Position',[0    0    1/3    1 ]);
    %set(h(1),'Position',[0.42    0.18    0.5    0.78 ]);
    %set(h(3),'Position',[0    0.18    1/3    0.78 ]);

    %     put the smad time course on top
    uistack(h(2),'top')
    set(h(2),'Color','none','Box','off')
    
    frm=getframe(fi);
    writeVideo(writerObj,frm);
end

close(writerObj);
