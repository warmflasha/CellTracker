function [acoords, fullIm]=alignManyPanelsAndorZstackMontage(direc,dims,chan,parrange,acoords)

if ~exist('parrange','var')
    parrange = 50:200;
end
imFiles=readAndorDirectory(direc);
tot_imgs=length(imFiles.m);
previmg=andorMaxIntensity(imFiles,0,0,chan);
si=size(previmg);

if exist('acoords','var')
    fullIm=zeros(si(1)*dims(1),si(2)*dims(2));

    for ii=0:(tot_imgs-1)

    currinds = acoords(ii+1).absinds;
    if nargout == 2
        currimg=andorMaxIntensity(imFiles,ii,0,chan);
        fullIm(currinds(1):(currinds(1)+si(1)-1),currinds(2):(currinds(2)+si(2)-1))=currimg;
    end
    end
    return;
end



perpsearch = 20;

zz=zeros(tot_imgs,2);
zz=mat2cell(zz,ones(tot_imgs,1));

acoords=struct('wabove',zz,'wside',zz,'absinds',zz);


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

%put it together
if nargout == 2
    fullIm=zeros(si(1)*dims(2),si(2)*dims(1));
end
%currinds=[1 1];
for ii=0:(tot_imgs-1)
    coord2 = floor(ii/dims(1))+1;
    coord1 = ii-(coord2-1)*dims(1)+1;
    
    currinds=[(coord2-1)*si(1)+1 (coord1-1)*si(2)+1];
    for kk=2:coord2
        currinds(1)=currinds(1)-acoords(ii-(kk-2)*dims(1)+1).wabove(1);
    end
    for mm=2:coord1
        currinds(2)=currinds(2)-acoords(ii-mm+2+1).wside(1);
    end
    acoords(ii+1).absinds=currinds;
    if nargout == 2
        currimg=andorMaxIntensity(imFiles,ii,0,chan);
        fullIm(currinds(1):(currinds(1)+si(1)-1),currinds(2):(currinds(2)+si(2)-1))=currimg;
    end
    
end
