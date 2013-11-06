function imgs=getColoniesImages(matfile,colsize,maxims)
%imgs=getColoniesImages(matfile,colsize,maxims)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function to get colony images from a matfile
%colsize gives theh size of the colonies 1=1000um, 2=500um,
%3=250um,4 = small.
%maxims=maximum number of images to return. If not specified will be 
%min(#number of colonies of that size,20)

pp=load(matfile,'plate1');

if ~exist('colsize','var')
    colsize=1;
end

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

if ~exist('maxims','var')
    maxims=min(length(inds),20);
else
    maxims=min(maxims,length(inds));
end

for ii=1:maxims
    imgs{ii}=pp.plate1.getColonyImages(inds(ii));
end