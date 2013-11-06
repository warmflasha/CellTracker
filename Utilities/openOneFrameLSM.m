function imgs=openOneFrameLSM(filename,tt,zz,chan)

fdata=lsminfo(filename);
nz=fdata.DimensionZ;

imnum=(tt-1)*nz+zz;
imnum=2*imnum-1;
imgs=tiffread27(filename,imnum);

if exist('chan','var') && chan > 0
    imgs=imgs.data{chan};
else
    imgs=imgs.data;
end