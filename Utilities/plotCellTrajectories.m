function plotCellTrajectories(cells,pictimes,mintrajlength,maxnum)

q=1; ii=1;
ncells=length(cells);
while ii < ncells && q < maxnum
    if sum(cells(ii).data(:,7) > 0) > mintrajlength
        nm=cells(ii).data(:,5);
        nf=cells(ii).data(:,6);
        nc=cells(ii).data(:,7);
        inds=find(nc>0);
        tt=pictimes(cells(ii).onframes(inds));
        rats=nf(inds)./nc(inds);
        figure, plot(tt,rats,'g.-','LineWidth',2,'MarkerSize',12);
        hold on;
        plot(tt,nm(inds)/nm(inds(1)),'r.-','LineWidth',2,'MarkerSize',12);
        q=q+1;
    end
    ii=ii+1;
end