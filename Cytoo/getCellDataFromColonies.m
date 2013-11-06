function outdat=getCellDataFromColonies(matfile,collist)

cl=load(matfile,'colonies');

ncol=length(collist);

c2=cl.colonies(collist);

ncells=[c2.ncells];
totcells=sum(ncells);

outdat=zeros(totcells,size(c2(1).data,2));
q=1;
for ii=1:ncol
    outdat(q:q+ncells(ii)-1,:)=c2(ii).data;
    q=q+ncells(ii);
end

