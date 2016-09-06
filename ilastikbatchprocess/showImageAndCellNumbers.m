function showImageAndCellNumbers(imagestack,trackstack,chan,frame)

imgreader = bfGetReader(imagestack);
maskreader = bfGetReader(trackstack);

iplane = maskreader.getIndex(0, 0, frame - 1) + 1;
mask = bfGetPlane(maskreader,iplane);


iplane = imgreader.getIndex(frame - 1, chan, 0) + 1;
nucimg = bfGetPlane(imgreader,iplane);

maskbin = mask > 1; 

stats = regionprops(maskbin,mask,'MeanIntensity','Centroid');
xy = stats2xy(stats);

m_int = [stats.MeanIntensity];

showImg({nucimg}); hold on;
for ii = 1:length(m_int)
    text(xy(ii,1),xy(ii,2),int2str(m_int(ii)),'Color','r');
end