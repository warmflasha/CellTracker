function maxind=findMaxOfAverage(matfile,cols,sparam)
figure; 
[savg tt]=mkAveragePlot(matfile,cols,0,'k.'); hold on;
spl=csaps(tt,savg,sparam);
splval=fnval(spl,tt);
[maxval maxind]=extrema(splval);

plot(tt,splval,'r-','LineWidth',2);
plot(tt(maxind),splval(maxind),'bx','MarkerSize',14,'LineWidth',2);