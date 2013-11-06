function [datout errout]=runAvgOverColonies(colonies,colinds,nbin,normtofirst,ftouse)

ndat=size(colonies(1).data,2);
ndat=ndat-7;
ndat=ndat/2;

if ftouse==1
    ff=@rrat;
    ncol=ndat;
elseif ftouse==2
    ff=@rrat2;
    ncol=ndat;
elseif ftouse==3
    ff=@rbdat;
    ncol=2*ndat+7;
end

[datout errout]=avgOverColonies(colonies,ff,colinds,[nbin ncol],normtofirst);




function [datout errout]=avgOverColonies(colonies,dfunc,colinds,doutsize,normtofirst)

ncol=length(colinds);
datout=zeros(doutsize); errout=datout; counter=datout;
for ii=1:ncol
    dat=dfunc(colonies(colinds(ii)));
    if sum(sum(isnan(dat))) > 0
        continue;
    end
    if normtofirst
        dat=dat./dat(ones(size(dat,1),1),:);
    end
    nrow=size(dat,1);
    nrow=min(nrow,doutsize(1));
    datout(1:nrow,:)=datout(1:nrow,:)+dat(1:nrow,:);
    errout(1:nrow,:)=errout(1:nrow,:)+dat(1:nrow,:).*dat(1:nrow,:);
    counter(1:nrow,:)=counter(1:nrow,:)+ones(nrow,doutsize(2));
end

datout=datout./counter;
errout=errout./counter-datout.*datout;
errout=sqrt(errout);

function rr=rrat(xx)
    rr=xx.rat;

    
function rr=rrat2(xx)
    rr=xx.rat2;
    
function rr=rbdat(xx)
    rr=xx.bdata;