function alldat=mkFullCytooPlotPeaks(matfile,returndat)

if ~exist('returndat','var')
    returndat=0;
end

pp=load(matfile);
peaks=pp.peaks;
ac=pp.acoords;

cc=colorcube(19);
figure; hold on;
for ii=1:length(peaks)
    if ~isempty(peaks{ii})
    toadd=[ac(ii).absinds(2) ac(ii).absinds(1)];
    dtoplot=bsxfun(@plus,peaks{ii}(:,1:2),toadd);
    if returndat
        alldat(q:(q+col(ii).ncells-1),:)=[dtoplot col(ii).data(:,3:end)];
        q=q+col(ii).ncells;
    end
    plot(dtoplot(:,2),dtoplot(:,1),'.','Color',cc(mod(ii,19)+1,:));
    text(toadd(1),toadd(2),int2str(ii),'Color','m');
    end
end


