function [mm pictimes]=peaksAverage(matfile,cols,ps)
if ~exist('ps','var')
    ps='k.-';
end

load(matfile,'peaks','pictimes');

xx=min(length(peaks),length(pictimes));

for ii=1:xx
    if isempty(peaks{ii})
        mm(ii)=NaN;
        continue;
    end
    if length(cols)==1
        mm(ii)=meannonan(peaks{ii}(:,cols));
    else
        mm(ii)=meannonan(peaks{ii}(:,cols(1))./peaks{ii}(:,cols(2)));
    end
end

mm=mm(1:xx); pictimes=pictimes(1:xx);

plot(pictimes(1:xx),mm(1:xx),ps,'LineWidth',2);
