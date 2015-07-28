function acoords=alignManyPanelsAndorZstackMontage(direc,dims,chan,parrange)

if ~exist('parrange','var')
    parrange = 50:200;
end

imFiles=readAndorDirectory(direc);

perpsearch = 20;

tot_imgs=length(imFiles.m);
zz=zeros(tot_imgs,2);
zz=mat2cell(zz,ones(tot_imgs,1));

acoords=struct('wabove',zz,'wside',zz,'absinds',zz);
previmg=andorMaxIntensity(imFiles,0,0,chan);

%si=size(previmg);

for ii=0:(tot_imgs-1)
    coord2 = floor(ii/dims(1))+1;
    coord1 = ii-(coord2-1)*dims(1)+1;
    currimg=andorMaxIntensity(imFiles,ii,0,chan);
    if coord1 > 1 %if not in left, align with left
        [~ , ind, ind2, sf]=alignTwoImages(previmg,currimg,4,parrange,perpsearch);
        acoords(ii+1).wside=[ind ind2 sf];
    else
        acoords(ii+1).wside=[0 0];
    end
    previmg=currimg;
    if coord2 > 1 %align with left
        leftimgind=ii-dims(1);
        leftimg=andorMaxIntensity(imFiles,leftimgind,0,chan);
        [~, ind, ind2, sf]=alignTwoImages(leftimg,currimg,1,parrange,perpsearch);
        acoords(ii+1).wabove=[ind ind2 sf];
    else
        acoords(ii+1).wabove=[0 0];
    end
    
end
