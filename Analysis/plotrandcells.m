function plotrandcells(matfile,ncells)

load(matfile,'cells2','pictimes');

ginds=find([cells2.good]);
rp=randperm(length(ginds));
cellstoplot=ginds(rp(1:ncells));
figure; hold all;
for ii=1:length(cellstoplot)
    cc=cellstoplot(ii);
    plot(pictimes(cells2(cc).onframes),cells2(cc).data(:,9)./cells2(cc).data(:,10));
end
hold off;
ylim([0.5 2]);