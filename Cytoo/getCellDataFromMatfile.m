function outdat=getCellDataFromMatfile(matfile,colsize)

pp=load(matfile,'plate1');

switch colsize
    case 1
        inds=pp.plate1.inds1000;
    case 2
        inds=pp.plate1.inds500;
    case 3
        inds=pp.plate1.inds250;
    case 4
        inds=pp.plate1.indsSm;
    otherwise
        inds=pp.plate1.inds1000;
        disp('WARNING: invalid colsize, must be 1-4, defaulting to 1');
end

ncol=length(inds);

c2=pp.plate1.colonies(inds);

ncells=[c2.ncells];
totcells=sum(ncells);

outdat=zeros(totcells,size(c2(1).data,2));
q=1;
for ii=1:ncol
    outdat(q:q+ncells(ii)-1,:)=c2(ii).data;
    q=q+ncells(ii);
end

