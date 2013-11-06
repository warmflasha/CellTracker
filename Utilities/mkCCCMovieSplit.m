function [ttuse ppuse lig]=mkCCCMovieSplit(direc,filekeyword,matfile,imcol,outfile,preloaddata)

ytick1=0.6:0.2:1.6;
ytick2=0:0.5:1;

[~, ff]=folderFilesFromKeyword(direc,filekeyword);

[ppuse ttuse]=peaksAverage(matfile,[6 7]);

nframes=min(length(ppuse),length(ff));

%Make the video objects
writerObj=VideoWriter([outfile '_mov.avi']);
writerObj2=VideoWriter([outfile '_graph.avi']);
writerObj.FrameRate=nframes/15; % movie will be 15 sec long
writerObj2.FrameRate=nframes/15;
open(writerObj); open(writerObj2);

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
rect=[200 200  250 500];
fi=figure;
set(fi,'Position',[100    100    rect(3)    rect(4) ])

set(fi,'Color','k');
fi2=figure;
set(fi2,'Color','k');
nframes=10;
for ii=1:nframes
    img=imread([direc filesep ff(ii).name]);
    im2show=imcrop(img,rect);
    
    %     smooth the picture
    myfilter = fspecial('gaussian',[6 6], 2);
    im2show = imfilter(im2show, myfilter, 'replicate');
    
    %     if ii==1
    %         imL=stretchlim(img,[0.1 0.98]);
    %     end
    
    imL=stretchlim(img,[0.49 0.995]);
    
    im2show=imadjust(im2show,imL);
    im2show=cat(3,imcol(1)*im2show,imcol(2)*im2show,imcol(3)*im2show);
    
    figure(fi); cla;
    imshow(im2show);
    
    if max(ttuse) > 30
        xtickuse=0:10:max(ttuse);
    else
        xtickuse=0:5:max(ttuse);
    end
    
    figure(fi2); cla; hold on;
    
    [AX H1 H2]=plotyy(ttuse(1:ii),ppuse(1:ii),ttuse(1:ii),lig(1:ii));
    maxy=max(ppuse); miny=min(ppuse);
    
    set(AX(1),'Color','k','YColor',imcol,'XColor','w','YTick',ytick1,'XTick',xtickuse,'FontSize',14);
    set(AX(2),'YColor','r','YTick',ytick2,'Xcolor','w','XTick',xtickuse,'FontSize',14);
    set(H1,'Color',imcol,'LineWidth',4,'HandleVisibility','off');
    set(H2,'Color','r','LineWidth',2,'LineStyle','--','HandleVisibility','off');
    
    xlim(AX(1),[0 max(ttuse)]);
    xlim(AX(2),[0 max(ttuse)]);
    if exist('preloaddata','var')
        for kk=1:length(preloaddata)
            axes(AX(1)); hold on;
            pl1{kk}=plot(preloaddata(kk).x1,preloaddata(kk).y1,'Color',preloaddata(kk).col,'LineWidth',2);
            axes(AX(2)); hold on;
            pl2{kk}=plot(preloaddata(kk).x2,preloaddata(kk).y2,'Color',preloaddata(kk).col,...
                'LineWidth',2,'HandleVisibility','off');
            allleg{kk}=preloaddata(kk).leg;
            
            
            
            maxy=max(maxy,max(preloaddata(kk).y1));
            miny=min(miny,max(preloaddata(kk).y1));
        end
        legend(allleg,'FontSize',14,'Location','NorthEast','Color','w')
        for kk=1:length(preloaddata)
            uistack(pl1{kk}(end:-1:1),'bottom');
            uistack(pl2{kk}(end:-1:1),'bottom');
        end
    end
    ylim(AX(1),[miny-0.1 maxy+0.1]);
    ylim(AX(2),[-0.05 max(lig)+0.05]);
    
    %     put titles to axis
    
    set(get(AX(2),'Xlabel'),'String','time (hrs)','FontSize',18,'FontName','Helvetica','FontWeight','Bold')
    set(get(AX(1),'Ylabel'),'String','Smad 4 nuc/cyto','FontSize',18,'FontName','Helvetica','FontWeight','Bold')
    set(get(AX(2),'Ylabel'),'String','[TGF-\beta1] (ng/ml)','FontSize',18,'FontName','Helvetica','FontWeight','Bold')
    
    %  resize stuff
      h = get(fi2,'Children');
%     %set(h(3),'Position',[0    0    1/3    1 ]);
%     set(h(1),'Position',[0.42    0.18    0.5    0.78 ]);
%     set(h(3),'Position',[0    0.18    1/3    0.78 ]);

    %     put the smad time course on top
    uistack(h(2),'top')
    set(h(2),'Color','none','Box','off')
    
    frm=getframe(fi);
    writeVideo(writerObj,frm);
    
    frm2=getframe(fi2);
    writeVideo(writerObj2,frm2);
end

close(writerObj);
close(writerObj2);
