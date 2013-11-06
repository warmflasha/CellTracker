function [avg, err]=averageColoniesWithBadInds(cD,badinds,datasize)
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
            datnow = cD{jj}(ii).data(1:dsize_use);
            %cib=cD{jj}(ii).cellsinbin(1:dsize_use);
            cib=ones(dsize_use,1);
            avg(jj,1:dsize_use)=avg(jj,1:dsize_use)+(datnow.*cib)';
            err(jj,1:dsize_use)=err(jj,1:dsize_use)+((datnow.*cib).^2)';
            counter(jj,1:dsize_use)=counter(jj,1:dsize_use)+cib';
        end
    end
end
inds=counter > 0;
avg(inds)=avg(inds)./counter(inds);
err(inds)=sqrt(err(inds)./counter(inds)-avg(inds).*avg(inds));