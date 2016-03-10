function M = mkOneCellMovie2D(cellobj,imagestack,chan)


nf = length(cellobj.onframes);
imgreader = bfGetReader(imagestack);


figure;
for ii = 1:nf
    
    tt = cellobj.onframes(ii); 
    iplane = imgreader.getIndex(tt-1, chan(1), 0) + 1;
    img = bfGetPlane(imgreader,iplane);
    
    clf;
    showImg({img}); hold on;
    plot(cellobj.position(ii,1),cellobj.position(ii,2),'r.','MarkerSize',20);
    title(['Time = ' tt],'FontSize',20);
    M(ii) = getframe;
end

