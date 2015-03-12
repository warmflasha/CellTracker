function [colonies peaks]=peaksToColoniesSC(matfile)

pp=load(matfile,'peaks','acoords','imgfiles','dims');
peaks=pp.peaks;
ac=pp.acoords;
dims=pp.dims;

p=ANremoveIncompletePeaks(peaks);%AN
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

allinds=NewColoniesAW(pts);% changed to a new function, the output is not a cell array
%[~, S]=alphavol(pts,20);%original value 100
%groups=getUniqueBounds(S.bnd);   % S.bnd - Boundary facets (Px2 or Px3)
%allinds=assignCellsToColonies(pts,groups);
%alldat=[alldat full(allinds)];

alldat = [alldat, allinds];

ngroups = max(allinds);
%Make colony structure
for ii=1:ngroups;
    cellstouse=allinds==ii;
    colonies(ii)=colony(alldat(cellstouse,:),ac,dims,[2048 2048],pp.imgfiles);%[2048 2048]%[1024 1344]
end

%put data back into peaks
for ii=1:length(peaks)
    cellstouse=alldat(:,end-1)==ii;
    peaks{ii}=[peaks{ii} alldat(cellstouse,end-1:end)];
end
