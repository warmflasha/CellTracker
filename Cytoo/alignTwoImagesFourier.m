function [fi, rowshift, colshift] = alignTwoImagesFourier(im1,im2,side,maxov)
%   side = 1  im2 below im1
%          2  im2 left of im1
%          3  im2 above im1
%          4  im2 right of im1

ov = maxov;

switch side
    case 1
        pix1=im1((end-ov):end,:);
        pix2=im2(1:(1+ov),:);
    case 2
        pix1=im1(:,1:(1+ov));
        pix2=im2(:,(end-ov):end);
    case 3
        pix1=im1(1:(1+ov),:);
        pix2=im2((end-ov):end,:);
    case 4
        pix1=im1(:,(end-ov):end);
        pix2=im2(:,1:(1+ov));
end

[~, rowshift, colshift] = registerTwoImages(pix1,pix2);

si = size(im1);

if side == 1 || side == 3
    rowshift = maxov - abs(rowshift);
    fi = uint16(zeros(2*si(1)-abs(rowshift),si(2)+abs(colshift),2));
else
    colshift = maxov-colshift;
    fi = uint16(zeros(si(1)+abs(rowshift),2*si(2)-abs(colshift),2));
end
switch side
    case 1
        if colshift > 0
            fi(1:si(1),1:si(2),1) = im1;
            fi(si(1)-abs(rowshift)+1:end,colshift+1:end,2) = im2;
        else
            fi(1:si(1),abs(colshift)+1:end,1) = im1;
            fi(si(1)-abs(rowshift)+1:end,1:si(2),2) = im2;
        end
    case 2
       
    case 3
         if colshift > 0
            fi(1:si(1),1:si(2),1) = im2;
            fi(si(1)-abs(rowshift)+1:end,colshift+1:end,2) = im1;
        else
            fi(1:si(1),1:si(2),1) = im2;
            fi(si(1)-abs(rowshift)+1:end,abs(colshift)+1:end,2) = im1;
        end
    case 4
        if rowshift > 0
            fi(1:si(1),1:si(2),1) = im1;
            fi(rowshift+1:end,si(1)-abs(colshift)+1:end,2) = im2;
        else
            fi(abs(rowshift)+1:end,1:si(2),1) = im1;
            fi(1:si(1),si(1)-abs(colshift)+1:end,2) = im2;
        end
end

m1 = fi(:,:,1);
m2 = fi(:,:,2);

m1(m1==0) = m2(m1==0);
m2(m2==0) = m1(m2==0);

fi = mean(cat(3,m1,m2),3);

end