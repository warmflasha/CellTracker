function acoords=alignManyPanelsMM(files,parrange,maxims)

dims = [length(files.pos_x) length(files.pos_y)];

if ~exist('parrange','var')
    parrange=1:200;
end

if ~exist('maxims','var')
    maxims=dims(1)*dims(2);
end

perpsearch = 20;

tot_imgs=dims(1)*dims(2);
zz=zeros(tot_imgs,2);
zz=mat2cell(zz,ones(tot_imgs,1));

acoords=struct('wabove',zz,'wside',zz,'absinds',zz);

%previmg=imread([direc filesep imFiles(1).name]);
for jj=1:dims(1)
    for ii=1:dims(2)
        currimgind=sub2ind(dims,jj,ii);
        disp(currimgind);
        if currimgind <= maxims
            fname = mkMMfilename(files,jj-1,ii-1);
            currimg=imread(fname{1});
            if ii > 1 %if not in top row, align with above
                [~ , ind, ind2, sf]=alignTwoImages(previmg,currimg,1,parrange,perpsearch);
                acoords(currimgind).wabove=[ind ind2 sf];
            else
                acoords(currimgind).wabove=[0 0];
            end
            previmg=currimg;
            if jj < dims(1) %align with left
                leftimgnm = mkMMfilename(files,jj,ii-1);
                leftimg=imread(leftimgnm{1});
                [~, ind, ind2, sf]=alignTwoImages(leftimg,currimg,4,parrange,perpsearch);
                acoords(currimgind).wside=[ind ind2 sf];
            else
                acoords(currimgind).wside=[0 0];
            end
        end
    end
end

si=size(previmg);

%currinds=[1 1];
for jj=1:dims(1)
    for ii=1:dims(2)
        currimgind=sub2ind(dims,jj,ii);
        if currimgind <= maxims
            currinds=[(dims(1)-jj)*si(1)+1 (ii-1)*si(2)+1];
            for kk=2:ii
                currinds(2)=currinds(2)-acoords(sub2ind(dims,jj,kk)).wabove(1);
            end
            for mm=jj:dims(1)
                currinds(1)=currinds(1)-acoords(sub2ind(dims,mm,ii)).wside(1);
            end
            acoords(currimgind).absinds=currinds;
        end
    end
end





