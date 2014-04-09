function fi=getImagesFromMatfile(matfile,colsize,maximgs,rs_sc,first_img)

if ~exist('first_img','var')
    first_img=1;
end

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

nimgs=min(length(inds)-first_img+1,maximgs);

for ii=1:nimgs
    fi{ii}=pp.plate1.getColonyImages(inds(ii+first_img-1));
end

if exist('rs_sc','var')
    for ii=1:nimgs
        for jj=1:length(fi{ii})
            fi{ii}{jj}=imresize(fi{ii}{jj},rs_sc);
        end
    end
end