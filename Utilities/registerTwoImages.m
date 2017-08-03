function [imgstack, row_shift, col_shift] = registerTwoImages(img1in,img2in,chan,keepsize)
% function to register two images. outputs a stack with the two images
% registered as well as the row and column shifts between the images.
% if the images are already stacks, will use the channel chan for alignment
% (default 1) but will make stacks containing all channels.
% setting keepsize = true will force to return an image the same size as
% the inputs. 

if exist('chan','var')
    img1 = img1in(:,:,chan);
    img2 = img2in(:,:,chan);
else
    img1 = img1in(:,:,1);
    img2 = img2in(:,:,1);
end

if ~exist('keepsize','var')
    keepsize = false;
end

img1ft = fft2(img1); img2ft = fft2(img2);
CC = ifft2(img1ft.*conj(img2ft));

[row_shift, col_shift] = find(abs(CC)==max(max(abs(CC))));
[nr, nc] = size(img2ft);
Nr = ifftshift(-fix(nr/2):ceil(nr/2)-1);
Nc = ifftshift(-fix(nc/2):ceil(nc/2)-1);
row_shift = Nr(row_shift);
col_shift = Nc(col_shift);

for ii = 1:size(img1in,3)
    if row_shift > 0 % img2 above img 1
        if col_shift > 0 %img 2 left of img1
            img2shift(:,:,ii) = uint16(zeros(size(img2)+abs([row_shift, col_shift])));
            img2shift(row_shift+1:end,col_shift+1:end,ii) = img2in(:,:,ii);
            img1shift(:,:,ii) =uint16(zeros(size(img2shift(:,:,ii))));
            img1shift(1:nr,1:nc,ii) = img1in(:,:,ii);
        else %img2 right of img1
            img2shift(:,:,ii) = uint16(zeros(size(img2)+abs([row_shift, col_shift])));
            img2shift(row_shift+1:end,1:nc,ii) = img2in(:,:,ii);
            img1shift(:,:,ii) =uint16(zeros(size(img2shift(:,:,ii))));
            img1shift(1:nr,abs(col_shift)+1:end,ii) = img1in(:,:,ii);
        end
    else %img2 below img 1
        if col_shift > 0 %img 2 left of img1
            img2shift(:,:,ii) = uint16(zeros(size(img2)+abs([row_shift, col_shift])));
            img2shift(1:nr,col_shift+1:end,ii) = img2in(:,:,ii);
            img1shift(:,:,ii) =uint16(zeros(size(img2shift(:,:,ii))));
            img1shift(abs(row_shift)+1:end,1:nc,ii) = img1in(:,:,ii);
        else %img2 right of img1
            img2shift(:,:,ii) = uint16(zeros(size(img2)+abs([row_shift, col_shift])));
            img2shift(1:nr,1:nc,ii) = img2in(:,:,ii);
            img1shift(:,:,ii) =uint16(zeros(size(img2shift(:,:,ii))));
            img1shift(abs(row_shift)+1:end,abs(col_shift)+1:end,ii) = img1in(:,:,ii);
        end
    end
end

if keepsize
    rs = max(abs(row_shift),2); cs = max(abs(col_shift),2); 
    img1shift = img1shift(floor(rs/2):floor(rs/2)+nr-1,...
        floor(cs/2):floor(cs/2)+nc-1,:);
    img2shift = img2shift(floor(rs/2):floor(rs/2)+nr-1,...
        floor(cs/2):floor(cs/2)+nc-1,:);
end

imgstack = cat(3,img1shift,img2shift);