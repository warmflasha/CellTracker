%function [acoords, fullIm]=alignManyPanelsmtiffmont(direc,filename, dir1,dir2,dims,parrange,maxims)
clear all

direc = '.';
img = dir(direc);
%%
%t = 1;
tic;
for t = 1;
%for t = 232:3:999

        

dir1 = 1;
dir2 = 4;
dims = [8 5];
parrange = 150:250;
maxims = 82;
perpsearch = 20;

%get the image file names
%[~, imFiles]=folderFilesFromKeyword(direc,imKeyWord);

tot_imgs=maxims;
zz=zeros(tot_imgs,2);
zz=mat2cell(zz,ones(tot_imgs,1));

acoords=struct('wabove',zz,'wside',zz,'absinds',zz);

%previmg=imread([direc filesep imFiles(1).name]);
previmg = imread(img(4).name);
si=size(previmg);

%%
m=2;
for jj=1:dims(2)
    for ii=1:dims(1)
        currimgind=2*m;
        m=m+1;
        if currimgind <= maxims
            %currimg=imread([direc filesep imFiles(currimgind).name]);
            currimg = imread(img(currimgind).name,t);
            if jj > 1 %if not in top row, align with above
                previmg = imread(img((currimgind-dims(1)*2)).name,t);
                [~ , ind, ind2, sf]=alignTwoImages(previmg,currimg,dir1,parrange,perpsearch);
                acoords(currimgind).wabove=[ind ind2 sf];
            else
                acoords(currimgind).wabove=[0 0];
            end
            %previmg=currimg;
            if ii > 1 %align with left
                %leftimgind=currimgind-dims(1);
                leftimgind=currimgind-2;
                %leftimg=imread([direc filesep imFiles(leftimgind).name]);
                leftimg = imread(img(leftimgind).name, t);
                [~, ind, ind2, sf]=alignTwoImages(leftimg,currimg,dir2,parrange,perpsearch);
                acoords(currimgind).wside=[ind ind2 sf];
            else
                acoords(currimgind).wside=[0 0];
            end
        end
    end
end



%%
for ch = 1:3
newim{t}{ch} = zeros(dims(2)*1024, dims(1)*1024);
end

%newim(1:1024, 1:1024) = img{1}{1,1};
idrl = 0;
idcl = 1024;
imn = 2;


for j = 1:dims(2)
    idcl = 1024;
    
for i = 1:dims(1)
    ova = acoords(2*imn).wabove(1);
    ovl = acoords(2*imn).wside(1);
    
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
    
    for ch = 1:3
    newim{t}{ch}(idr(i):idrl(i), idc:idcl) = imread(img(2*imn).name,t+ch-1);
  
    end
    imn = imn+1;
    
end
end

%figure; imshow(newim,[]);
  
    
end   
 toc;   
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    





