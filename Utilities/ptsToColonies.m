function allinds=ptsToColonies(dat,mkplot)
pts=dat(:,1:2);
[~, S]=alphavol(pts,100);
groups=getUniqueBounds2(S.bnd);
allinds=assignCellsToColonies(pts,groups);
ncolors=100;
if exist('mkplot','var') && mkplot
    cc=colorcube(ncolors);
    figure; hold on;
    for ii=1:length(groups)
        plot(pts(allinds==ii,2),pts(allinds==ii,1),'.','Color',cc(mod(ii,ncolors-1)+1,:));
        %plot(pts(groups{ii},1),pts(groups{ii},2),'ks');
    end
end
