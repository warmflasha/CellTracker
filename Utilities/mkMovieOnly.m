function [ttuse ppuse lig]=mkCCCMovieSplit(direc,filekeyword,matfile,imcol,outfile,preloaddata)

ytick1=0.6:0.2:1.6;
ytick2=0:0.5:1;

[~, ff]=folderFilesFromKeyword(direc,filekeyword);

nframes=length(ff);

%Make the video objects
writerObj=VideoWriter([outfile]);
writerObj.FrameRate=nframes/15; % movie will be 15 sec long
open(writerObj);



%fi=figure;
%set(fi,'Position',[100    100    rect(3)    rect(4) ])

%set(fi,'Color','k');
%fi2=figure;
rect=[200 200  250 500];

nframes=10;
for ii=1:nframes
    img=imread([direc filesep ff(ii).name]);
    %im2show=imcrop(img,rect);
    im2show=img;
    %     smooth the picture
    myfilter = fspecial('gaussian',[6 6], 2);
    im2show = imfilter(im2show, myfilter, 'replicate');
    
    %     if ii==1
    %         imL=stretchlim(img,[0.1 0.98]);
    %     end
    
    imL=stretchlim(img,[0.49 0.995]);
    
    im2show=imadjust(im2show,imL);
    im2show=cat(3,imcol(1)*im2show,imcol(2)*im2show,imcol(3)*im2show);
    
    imshow(im2show);
   
    frm=getframe;
    writeVideo(writerObj,frm);

end

close(writerObj);
