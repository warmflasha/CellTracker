function [mm pictimes]=peaksAverageExclBad(matfile,cols,ps)
if ~exist('ps','var')
    ps='k.-';
end

load(matfile,'peaks','pictimes');

for ii=1:length(peaks)
    
    if isempty(peaks{ii})
        mm(ii)=NaN;
        continue;
    end
    %exclude those with ratio too large
    inds1= peaks{ii}(:,6)./peaks{ii}(:,7) < 2;
    
    %exclude those not in colony
    distances=ipdm(peaks{ii}(:,1:2));
    nn_dist=sort(distances);
    nn_dist=nn_dist(2,:);
    meandist=mean(nn_dist);
    sddist=std(nn_dist);
    
    %Exclude those greater than 3 sigma away
    inds2= nn_dist < meandist+3*sddist;
    
    indsuse= inds1 & inds2';
    
    
    
    if length(cols)==1
        mm(ii)=meannonan(peaks{ii}(indsuse,cols));
    else
        mm(ii)=meannonan(peaks{ii}(indsuse,cols(1))./peaks{ii}(indsuse,cols(2)));
    end
end

plot(pictimes,mm,ps,'LineWidth',2);
