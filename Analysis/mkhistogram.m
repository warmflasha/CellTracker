function mkhistogram(peaks,frame,nbins,cols)

if length(cols)==1
nf=peaks{frame}(:,cols);
figure, hist(nf(nf>0),nbins);
elseif length(cols)==2k
    nf=peaks{frame}(:,cols(1));
    cf=peaks{frame}(:,cols(2));
    inds= cf > 0;
    figure, hist(nf(inds)./cf(inds),nbins);
end