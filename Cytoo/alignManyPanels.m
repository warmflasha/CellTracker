function [acoords, fullIm]=alignManyPanels(direc,imKeyWord,dir1,dir2,dims,parrange,maxims)

perpsearch = 20;

%get the image file names
[~, imFiles]=folderFilesFromKeyword(direc,imKeyWord);

tot_imgs=maxims;
zz=zeros(tot_imgs,2);
zz=mat2cell(zz,ones(tot_imgs,1));

acoords=struct('wabove',zz,'wside',zz,'absinds',zz);

previmg=imread([direc filesep imFiles(1).name]);
si=size(previmg);
for jj=1:dims(2)
    for ii=1:dims(1)
        currimgind=(jj-1)*dims(1)+ii;
        if currimgind <= maxims
            currimg=imread([direc filesep imFiles(currimgind).name]);
            if ii > 1 %if not in top row, align with above
                [~ , ind, ind2, sf]=alignTwoImages(previmg,currimg,dir1,parrange,perpsearch);
                acoords(currimgind).wabove=[ind ind2 sf];
            else
                acoords(currimgind).wabove=[0 0];
            end
            previmg=currimg;
            if jj > 1 %align with left
                leftimgind=currimgind-dims(1);
                leftimg=imread([direc filesep imFiles(leftimgind).name]);
                [~, ind, ind2, sf]=alignTwoImages(leftimg,currimg,dir2,parrange,perpsearch);
                acoords(currimgind).wside=[ind ind2 sf];
            else
                acoords(currimgind).wside=[0 0];
            end
        end
    end
end


%put it together
if nargout == 2
    fullIm=zeros(si(1)*dims(1),si(2)*dims(2));
end
%currinds=[1 1];
for jj=1:dims(2)
    for ii=1:dims(1)
        if (jj-1)*dims(1)+ii <= maxims
            currinds=[(ii-1)*si(1)+1 (jj-1)*si(2)+1];
            for kk=2:ii
                currinds(1)=currinds(1)-acoords((jj-1)*dims(1)+kk).wabove(1);
            end
            for mm=2:jj
                currinds(2)=currinds(2)-acoords((mm-1)*dims(1)+ii).wside(1);
            end
            currimgind=(jj-1)*dims(1)+ii;
            acoords(currimgind).absinds=currinds;
            if nargout == 2
                currimg=imread(imFiles(currimgind).name);
                fullIm(currinds(1):(currinds(1)+si(1)-1),currinds(2):(currinds(2)+si(2)-1))=currimg;
            end
        end
    end
end





