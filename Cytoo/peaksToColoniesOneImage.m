function colonies = peaksToColoniesOneImage(peaks)

alldat = peaks;
alphavol_param = 200;
pts = peaks(:,1:2);

[~, S]=alphavol(pts,alphavol_param);% this line was modified
groups=getUniqueBounds(S.bnd,pts);   % S.bnd - Boundary facets (Px2 or Px3)

allinds=assignCellsToColonies(pts,groups);
alldat=[alldat full(allinds)];
%Make colony structure for the alphavol algorythim
for ii=1:length(groups)
    disp(int2str(ii));
    cellstouse=allinds==ii;
    colonies(ii)=colony(alldat(cellstouse,:));
end


