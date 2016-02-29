function M = mkOneCellMovie(cellobj,imgdirec,chan)


nf = length(cellobj.onframes);
[~, imgfiles] = folderFilesFromKeyword(imgdirec,'.tif');


figure; 
for ii = 1:nf
    
    imgreader = bfGetReader(fullfile(imgdirec,imgfiles(cellobj.onframes(ii)).name));
    nz = imgreader.getSizeT;
    zplane = floor(cellobj.position(ii,3));
    
    
    for jj = -1:1
        q = 1;
        if zplane+jj > 0 && zplane + jj < nz
            iplane = imgreader.getIndex(0, chan(1), zplane+jj-1) + 1;
            img(:,:,q) = bfGetPlane(imgreader,iplane);
            q = q + 1;
        end
    end
    img = max(img,3);
    clf;
    showImg({img}); hold on; 
    plot(cellobj.position(ii,1),cellobj.position(ii,2),'r.','MarkerSize',20);
    title(['Zplane = ' int2str(zplane)],'FontSize',20);
    M(ii) = getframe;
end

    