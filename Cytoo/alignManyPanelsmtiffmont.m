%function [acoords, fullIm]=alignManyPanelsmtiffmont(direc,filename, dir1,dir2,dims,parrange,maxims)
clear all

direc = '.';
filename = 'Protocol18920161111_13038 PM.tif';
dir1 = 1;
dir2 = 4;
dims = [10 10];
parrange = 20:100;
maxims = 40;
perpsearch = 20;

%get the image file names
%[~, imFiles]=folderFilesFromKeyword(direc,imKeyWord);

%tot_imgs=maxims;

imFiles = filename;
img = bfopen(imFiles);

tot_imgs = size(img{1},1);

zz=zeros(tot_imgs,2);
zz=mat2cell(zz,ones(tot_imgs,1));

acoords=struct('wabove',zz,'wside',zz,'absinds',zz);

%previmg=imread([direc filesep imFiles(1).name]);
previmg = img{1}{1,1};
si=size(previmg);

for jj=1:dims(2)
    for ii=1:dims(1)
        currimgind=(jj-1)*dims(1)+ii;
        if currimgind <= maxims
            %currimg=imread([direc filesep imFiles(currimgind).name]);
            currimg = img{1}{currimgind, 1};
            if jj > 1 %if not in top row, align with above
                previmg = img{1}{(currimgind-dims(1)),1};
                [~ , ind, ind2, sf]=alignTwoImages(previmg,currimg,dir1,parrange,perpsearch);
                acoords(currimgind).wabove=[ind ind2 sf];
            else
                acoords(currimgind).wabove=[0 0];
            end
            %previmg=currimg;
            if ii > 1 %align with left
                %leftimgind=currimgind-dims(1);
                leftimgind=currimgind-1;
                %leftimg=imread([direc filesep imFiles(leftimgind).name]);
                leftimg = img{1}{leftimgind, 1};
                [~, ind, ind2, sf]=alignTwoImages(leftimg,currimg,dir2,parrange,perpsearch);
                acoords(currimgind).wside=[ind ind2 sf];
            else
                acoords(currimgind).wside=[0 0];
            end
        end
    end
end

%%

%%
newim = zeros(dims(2)*1024, dims(1)*1024);

%newim(1:1024, 1:1024) = img{1}{1,1};
idrl = 0;
idcl = 1024;
m = 1;

for j = 1:dims(2)
    idcl = 1024;
    
    for i = 1:dims(1)
        ova = acoords(m).wabove(1);
        ovl = acoords(m).wside(1);
        
        if(i==1)
            idc=1;
        else
            idc = idcl-ovl+1;
        end
        
        
        if(j ==1)
            idr(i) = 1;
        else
            idr(i) = idrl(i)-ova+1;
        end
        
        idrl(i) = idr(i)+1023;
        
        idcl = idc+1023;
        
        newim(idr(i):idrl(i), idc:idcl) = img{1}{m,1};
        m = m+1;
        
    end
end
figure; imshow(newim,[]);





























