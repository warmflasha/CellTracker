function [avg, err]=getCellDensity(cD,badinds,datasize)
%[avg, err]=averageColoniesWithBadInds(cD,badinds,datasize)
%-----------------------------------------------------------
%average over colonies, exclude indices in badinds
%cD is cell array as outputed by getColDataFromMatfile

avg=zeros(3,datasize);
err=zeros(3,datasize);
counter=zeros(3,datasize);
for ii=1:length(cD{1})
    if ~ismember(ii,badinds)
        for jj=1:length(cD)
            dsize_use=min(datasize,length(cD{jj}(ii).data));
            cib=cD{jj}(ii).cellsinbin(1:dsize_use);
            xx=linspace(0,500,30);
            areas=4*pi*xx.*xx;
            dattouse=cib./areas;
        end
    end
end
inds=counter > 0;
avg(inds)=avg(inds)./counter(inds);
err(inds)=sqrt(err(inds)./counter(inds)-avg(inds).*avg(inds));