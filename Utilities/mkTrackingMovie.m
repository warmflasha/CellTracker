function mkTrackingMovie(direc,filekeyword,matfile,imcol,outfile)

[~, ff]=folderFilesFromKeyword(direc,filekeyword);

peaks=1;
load([direc filesep matfile],'peaks');
pp=peaksAverage([direc filesep matfile],[6 7]);

nframes=min(length(pp),length(ff));

writerObj=VideoWriter(outfile);
writerObj.FrameRate=5;
open(writerObj);

rect=[50 50  250 500];
fi=figure;
set(fi,'Color','k');


for ii=1:nframes
    img=imread([direc filesep ff(ii).name]);
    %im2show=imcrop(img,rect);
    im2show=img;
    
    %     smooth the picture
    myfilter = fspecial('gaussian',[6 6], 2);
    im2show = imfilter(im2show, myfilter, 'replicate');
    imL=stretchlim(img,[0.49 0.995]);
    
    %     if ii==1
    %         imL=stretchlim(img,[0.05 0.99]);
    %     end
    im2show=imadjust(im2show,imL);
    im2show=cat(3,imcol(1)*im2show,imcol(2)*im2show,imcol(3)*im2show);
    
    figure(fi);
    imshow(im2show);
    hold on;
    plot(peaks{ii}(:,1),peaks{ii}(:,2),'r.');
    
    frm=getframe(fi);
    writeVideo(writerObj,frm);
    clf;
end

close(writerObj);
