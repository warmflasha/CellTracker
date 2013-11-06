function [colData cellsinbin]=getColDataFromMatfile(matfile,colsize,column,ncolumn,binsize,compfrom)


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

for ii=1:length(column)
    if length(ncolumn)==1
        ntouse=ncolumn;
    elseif length(ncolumn)==length(column)
        ntouse=ncolumn(ii);
    else
        error('length(ncolumn) must be 1 or length(column)');
    end
    [colData{ii}]=pp.plate1.getColonyData(inds,column(ii),ntouse,binsize,compfrom);
end
