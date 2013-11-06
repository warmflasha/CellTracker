function stemCellTestPlot(cells, ncell)
% to help with finding stem cell births, plot area, nuc-fluor, smad-nuc

    celln = cells(ncell);
    xx = celln.onframes;
    plot(xx',celln.data(:,3),'r', xx',celln.sdata(:,1),'g', xx',celln.sdata(:,2),'b');
    legend('area', 'nuc-fl', 'smad-nuc');
    title(['cell= ', num2str(ncell)]);
