function [binmean,binvect,binrawdat] = getbinnedmean(nms2,bnsz,binlow,binhigh,chandata,j,xx,param,titlestr)
% only bin the Smad4 nuctocytoo data
clear dat1;
clear dat2;
binvect = (binlow:bnsz:binhigh);
npts=size(binvect,2);
binmean = zeros(npts,size(nms2,2));% two columns (pSmad1, nuc:cyto smad4
normto = 2;
cyt = 5;
binrawdat = struct;

for k=1:size(nms2,2) % get the data into bins for all datasets
    binrawdat(k).datS4 = zeros(size(chandata{k}(:,1),1),npts);
    binrawdat(k).datS1 = zeros(size(chandata{k}(:,1),1),npts);
    dat1 = chandata{k}(:,j)./chandata{k}(:,normto);
    dat2 = chandata{k}(:,xx)./chandata{k}(:,cyt);
    for jj=1:npts        
        if jj == 1
            if k == 1
            disp([num2str(binvect(jj))]);
            end
    %binmean(jj,1)=mean(dat1(dat1<=binvect(jj)));
    binmean(jj,k)=mean(dat2(dat1<=binvect(jj)));
    binrawdat(k).datS4(1:size(dat2(dat1<=binvect(jj)),1),jj) = dat2(dat1<=binvect(jj));
    binrawdat(k).datS1(1:size(dat2(dat1<=binvect(jj)),1),jj) = dat1(dat1<=binvect(jj));
        end
        if jj>1
           if k == 1
               disp([num2str(binvect(jj-1)) ',' num2str(binvect(jj))]);
           end
           overlap = dat2(dat1>binvect(jj-1)&dat1<=binvect(jj));           
            if ~isempty((overlap)) && size(overlap,1)>100
                 disp(size(overlap,1));
%                 disp('smad1data');
    binmean(jj,k)=mean(overlap);
    binrawdat(k).datS4(1:size(overlap,1),jj) = overlap;
    binrawdat(k).datS1(1:size(overlap,1),jj) = dat1(dat1>binvect(jj-1)&dat1<=binvect(jj));

            end
            
        end
    end    
    
end

end