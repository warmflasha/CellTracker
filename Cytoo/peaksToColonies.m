function [colonies peaks]=peaksToColonies(matfile)

pp=load(matfile,'peaks','acoords','imgfiles','dims');
peaks=pp.peaks;
ac=pp.acoords;
dims=pp.dims;

peaks=removeDuplicateCells(peaks,ac);

k1=num2cell(ones(1,length(peaks)));
lens=cellfun(@size,peaks,k1);
totcells=sum(lens);

%get number of columns from first non-empty image
q=1; ncol=0;
while ncol==0
ncol=size(peaks{q},2);
q=q+1;
end

alldat=zeros(totcells,ncol+1);

q=1;
for ii=1:length(peaks)
    if ~isempty(peaks{ii})
        currdat=peaks{ii};
        toadd=[ac(ii).absinds(2) ac(ii).absinds(1)];
        currdat(:,1:2)=bsxfun(@plus,currdat(:,1:2),toadd);
        alldat(q:(q+lens(ii)-1),:)=[currdat ii*ones(lens(ii),1)];
        q=q+lens(ii);
    end
end
pts=alldat(:,1:2);

[~, S]=alphavol(pts,100);
groups=getUniqueBounds(S.bnd);
allinds=assignCellsToColonies(pts,groups);
alldat=[alldat full(allinds)];

%Make colony structure
for ii=1:length(groups)
    cellstouse=allinds==ii;
    colonies(ii)=colony(alldat(cellstouse,:),ac,dims,[],pp.imgfiles);
end

%put data back into peaks
for ii=1:length(peaks)
    cellstouse=alldat(:,end-1)==ii;
    peaks{ii}=[peaks{ii} alldat(cellstouse,end-1:end)];
end

