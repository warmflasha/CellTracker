function [avg, err]=radialAverageFromMatfile(matfile,colsize,column,ncolumn,binsize,compfrom)
%Function to get colony radial average from matfile contain a plate object
%assumes plate object is called plate1.
%colsize = 1 for 1000um, 2 for 500 um, 3 for 250 um, 4 for small
%compfrom = 0 means compute using dist from center, 1 use boundary, default
%0

if ~exist('compfrom','var')
    compfrom=0;
end

pp=load(matfile,'plate1');

switch colsize
    case 1
        inds=pp.plate1.inds1000;
    case 2
        inds=pp.plate1.inds800;
    case 3
        inds=pp.plate1.inds500;
    case 4
        inds=pp.plate1.inds200;
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
    [avg(ii,:) err(ii,:)]=pp.plate1.radialAverageOverColonies(inds,column(ii),ntouse,binsize,compfrom);
end