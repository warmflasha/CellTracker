function mkFlowPlots(data,col1,col2,normto,npoints,ps,newfig)

totalpoints=size(data,1);

if ~exist('newfig','var')
    newfig=1;
end

if ~exist('ps','var')
    ps='r.';
end

if exist('npoints','var')
    randord=randperm(totalpoints);
    inds=randord(1:npoints);
else
    inds=1:totalpoints;
end

d1=data(inds,col1);
d2=data(inds,col2);

if normto > 0
    normdat=data(inds,normto);
    d1=d1./normdat;
    d2=d2./normdat;
end
if newfig
figure; 
end

plot(d1,d2,ps);
