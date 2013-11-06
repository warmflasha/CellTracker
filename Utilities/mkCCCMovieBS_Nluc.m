% function [ttuse ppuse lig]=mkCCCMovie(direc,filekeyword,matfile,imcol,outfile,preloaddata)

% [ttuse ppuse lig]=mkCCCMovieBS('Z:\111113\ch21','green','Z:\111113\ch21out.mat',[0 1 0],'C:\Users\Marcel\Desktop\111113ch21.avi')
% [ttuse ppuse lig]=mkCCCMovieBS('Z:\120220\ch63','green','Z:\120220\ch63out.mat',[0 1 0],'C:\Users\Marcel\Desktop\120220ch63.avi')

direc = 'C:\Users\Marcel\Desktop\130319ch14\'
filekeyword = 'Nluc';
matfile = 'C:\Users\Marcel\Desktop\130319ch14\ch14out.mat'

imcol = [0 0 0.8];
outfile = 'C:\Users\Marcel\Desktop\130319ch14\vid1.avi'
preloaddata = 0;



ytick1=0.6:0.2:1.6;
ytick2=0:0.5:1;

[~, ff]=folderFilesFromKeyword(direc,filekeyword);

[ppuse ttuse]=peaksAverage(matfile,[6]);

% spline the data
pp=csaps(ttuse,ppuse,0.99);
ppuse = ppval(pp,ttuse);
%
nframes=min(length(ppuse),length(ff));

writerObj=VideoWriter(outfile)%,'Uncompressed AVI');
writerObj.FrameRate=nframes/15; % movie will be 15 sec long
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
rect=[0 0  256 336];
% create a figure
fi=figure(1);
clf
set(fi,'Color','w');
% define the figure size
set(fi,'Position',[100    100    rect(3)*3    rect(4) ])

StartFrame = 10
EndFrame = 60


for ii= StartFrame:EndFrame
    img=imread([direc filesep ff(ii).name]);
%     crop the picture
    im2show=imcrop(img,rect);
    
%     smooth the picture
    myfilter = fspecial('gaussian',[2 2], 2);
    im2show = imfilter(im2show, myfilter, 'replicate');
    
%     scale the picture
    if ii==1
        imL=stretchlim(img,[0.05 0.99]);
    end
    im2show=imadjust(im2show,imL);
    
    
% apply LUT
    im2show=cat(3,imcol(1)*im2show,imcol(2)*im2show,imcol(3)*im2show);
% display picture in left panel    
    subplot(1,2,1);
    imshow(im2show,[]);
    
%     set the X ticks for right panel
    if max(ttuse) > 30
        xtickuse=0:10:max(ttuse);
    else
        xtickuse=0:5:max(ttuse);
    end
    
    subplot(1,2,2); cla; hold on;
    
    [AX H1 H2]=plotyy(ttuse(StartFrame:ii)-25,ppuse(StartFrame:ii),ttuse(StartFrame:ii)-25,lig(StartFrame:ii));
    maxy=max(ppuse); miny=min(ppuse);

    set(AX(1),'Color','w','YColor',imcol,'XColor','k','YTick',ytick1,'XTick',xtickuse,'FontSize',14,...
        'XAxisLocation','top','XTicklabel','');
    set(AX(2),'YColor','k','YTick',ytick2,'Xcolor','k','XTick',xtickuse,'FontSize',14);
    set(H1,'Color',imcol,'LineWidth',2,'HandleVisibility','off');
    set(H2,'Color','k','LineWidth',2,'LineStyle','-','HandleVisibility','off');
%     
    xlim(AX(1),[ttuse(StartFrame)-25 max(ttuse)-25]);
    xlim(AX(2),[ttuse(StartFrame)-25 max(ttuse)-25]);

%     I commented what's next just for clarity 

%     if exist('preloaddata','var')
%         for kk=1:length(preloaddata)
%             axes(AX(1)); hold on;
%             pl1=plot(preloaddata(kk).x1,preloaddata(kk).y1,'Color',preloaddata(kk).col,'LineWidth',2);
%             axes(AX(2)); hold on;
%             pl2=plot(preloaddata(kk).x2,preloaddata(kk).y2,'Color',preloaddata(kk).col,...
%                 'LineWidth',2,'HandleVisibility','off');
%             allleg{kk}=preloaddata(kk).leg;
%             
%             uistack(pl1(end:-1:1),'bottom');
%             uistack(pl2(end:-1:1),'bottom');
% 
%             maxy=max(maxy,max(preloaddata(kk).y1));
%             miny=min(miny,max(preloaddata(kk).y1));
%         end
%         legend(allleg,'FontSize',14,'Location','NorthEast','Color','w')
%     end
    
    
    ylim(AX(1),[miny-0.05 maxy+0.1]);
    ylim(AX(2),[-0.05 max(lig)+0.1]);
    
%     put titles to axis

set(get(AX(2),'Xlabel'),'String','time (hrs)','FontSize',14,'FontName','Helvetica') 
set(get(AX(1),'Ylabel'),'String','cell luminescence','FontSize',14,'FontName','Helvetica') 
set(get(AX(2),'Ylabel'),'String','[TGF-\beta1] (ng/ml)','FontSize',14,'FontName','Helvetica') 
    
%  resize stuff   
    h = get(fi,'Children');
    set(h(3),'Position',[0    0    1/3    1 ]);
    set(h(1),'Position',[0.42    0.18    0.5    0.78 ]);
    
%     put the smad time course on top
    uistack(h(2),'top')
    set(h(2),'Color','none','Box','off')

    frm=getframe(fi);
    writeVideo(writerObj,frm);
end

close(writerObj);
