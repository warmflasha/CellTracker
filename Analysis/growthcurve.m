function [gc pictimes]=growthcurve(matfile,ps)

if ~exist('ps','var')
    ps='k.-';
end

load(matfile,'peaks','pictimes');

gc=zeros(length(peaks),1);
for ii=1:length(peaks)
    gc(ii)=length(peaks{ii});
end

plot(pictimes,gc,ps,'LineWidth',2);


