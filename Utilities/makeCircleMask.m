function mask=makeCircleMask(cc,rr,siz)

mask = false(siz);

tt=0:0.01:2*pi;
x1=cos(tt); y1=sin(tt);

for ii=1:length(rr)
    
    x=cc(ii,1)+rr(ii)*x1;
    y=cc(ii,2)+rr(ii)*y1;
    
    xf=floor(x); yf = floor(y);
    
    nogood = xf > siz(1) | xf < 1 | yf < 1 | yf > siz(2);
    
    xf(nogood)=[]; yf(nogood)=[];
    
    inds=sub2ind(siz,xf,yf);
    
    mask(inds) = true;
end
    
    