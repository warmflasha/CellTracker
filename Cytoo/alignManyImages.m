function [acoords, fi] = alignManyImages(imgs,maxov,acoords)

dims = size(imgs);
si=size(imgs{1,1});

if exist('acoords','var') % only paste stuff together
    if nargout == 2
        fullIm=zeros(si(1)*dims(1),si(2)*dims(2));
    end
    
    for jj=1:dims(2)
        for ii=1:dims(1)
            currinds=acoords(ii,jj).absinds;
            if nargout == 2
                currimg=imgs{ii,jj};
                fi(currinds(1):(currinds(1)+si(1)-1),currinds(2):(currinds(2)+si(2)-1))=currimg;
            end
        end
    end
    return;
end

for ii=1:dims(1)
    for jj=1:dims(2)
        currimgind=sub2ind(dims,ii,jj);
        currimg = imgs{ii,jj};
        if ii > 1 %if not in top row, align with above
            previmg = imgs{ii-1,jj};
            [~ , ind, ind2]=alignTwoImagesFourier(previmg,currimg,1,maxov);
            acoords(ii,jj).wabove=[ind ind2];
        else
            acoords(ii,jj).wabove=[0 0];
        end
        if jj > 1 %align with left
            leftimg=imgs{ii,jj-1};
            [fi, ind, ind2]=alignTwoImagesFourier(leftimg,currimg,4,maxov);
            acoords(ii,jj).wside=[ind2 ind];
        else
            acoords(ii,jj).wside=[0 0];
        end
    end
end


si=size(imgs{1,1});
if nargout == 2
    fullIm=zeros(si(1)*dims(1),si(2)*dims(2));
end

for jj=1:dims(2)
    for ii=1:dims(1)
        currinds=[(ii-1)*si(1)+1 (jj-1)*si(2)+1];
        for kk=2:ii
            currinds(1)=currinds(1)-acoords(kk,jj).wabove(1);
        end
        for mm=2:jj
            currinds(2)=currinds(2)-acoords(ii,mm).wside(1);
        end
        acoords(ii,jj).absinds=currinds;
        if nargout == 2
            currimg=imgs{ii,jj};
            fi(currinds(1):(currinds(1)+si(1)-1),currinds(2):(currinds(2)+si(2)-1))=currimg;
        end
    end
end


