function ncells=numCellsVsTime(matfile,ps)

load(matfile,'peaks','pictimes');

ncells=zeros(length(peaks),1);

for ii=1:length(peaks)
    ncells(ii)=length(peaks{ii});
end

%plot(pictimes,ncells,ps,'LineWidth',2); 
    