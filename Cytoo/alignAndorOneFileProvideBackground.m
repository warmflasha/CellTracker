function [acoords, fullIm]=alignAndorOneFileProvideBackground(filename,dims,chan,parrange,imsize,backgroundImage,acoords)
% Make an aligned image from one andor file in which the positions have
% been stored in different series. 
% inputs: 
% - filename: name of file
% - dims - dimensions of tiling. 2 element array. horizontal dimension
%       first
% -chan - channel to use (default 1)
% -parange - range to search in the parallel direction (i.e. range of
%   overlaps to search). default 50:200
% -imsize - size of each image. default 1024x1024
% -acoords - previously computed alignment. if input, wont realign, just
%   assemble the image
% -backgroundImage - image to use for subtracting background prior to
% stitching
% outputs: 
% - accords - alignment structure
% - fullIm - aligned image

if ~exist('parrange','var')
    parrange = 50:200;
end

if ~exist('imsize','var')
    imsize = [1024, 1024];
end
if ~exist('backgroundImage','var')
    subtractBG = 0;
else
    subtractBG = 1;
end
if ~exist('chan','var')
    chan = 1;
end

perpsearch = 20;

tot_imgs = dims(1)*dims(2);

if ~exist('acoords','var')
    zz=zeros(tot_imgs,2);
    zz=mat2cell(zz,ones(tot_imgs,1));
    
    acoords=struct('wabove',zz,'wside',zz,'absinds',zz);
    for ii=1:tot_imgs
        coord2 = floor((ii-1)/dims(1))+1;
        coord1 = ii-(coord2-1)*dims(1);
        currimg=bfopen_mod(filename,1,1,imsize(1),imsize(2),ii);
        currimg = currimg{ii}{chan,1};
        if subtractBG == 1
            currimg = imsubtract(currimg,backgroundImage);
        end
        if coord1 > 1 %if not in left, align with left
            [~ , ind, ind2, sf]=alignTwoImages(previmg,currimg,4,parrange,perpsearch);
            acoords(ii).wside=[ind ind2 sf];
        else
            acoords(ii).wside=[0 0];
        end
        previmg=currimg;
        if coord2 > 1 %align with above
            leftimgind=ii-dims(1);
            leftimg=bfopen_mod(filename,1,1,imsize(1),imsize(2),leftimgind);
            leftimg = leftimg{leftimgind}{chan,1};
            [~, ind, ind2, sf]=alignTwoImages(leftimg,currimg,1,parrange,perpsearch);
            acoords(ii).wabove=[ind ind2 sf];
        else
            acoords(ii).wabove=[0 0];
        end
        
    end
end

%put it together
si = imsize;
if nargout == 2
    fullIm=zeros(si(1)*dims(2),si(2)*dims(1));
end

for ii=1:tot_imgs
    coord2 = floor((ii-1)/dims(1))+1;
    coord1 = ii-(coord2-1)*dims(1);
    
    currinds=[(coord2-1)*si(1)+1 (coord1-1)*si(2)+1];
    for kk=2:coord2
        currinds(1)=currinds(1)-acoords(ii-(kk-2)*dims(1)).wabove(1);
    end
    for mm=2:coord1
        currinds(2)=currinds(2)-acoords(ii-mm+2).wside(1);
    end
    acoords(ii).absinds=currinds;
    if nargout == 2
        currimg=bfopen_mod(filename,1,1,imsize(1),imsize(2),ii);
        currimg = currimg{ii}{chan,1};
        if subtractBG == 1
            currimg = imsubtract(currimg,backgroundImage);
        end
        fullIm(currinds(1):(currinds(1)+si(1)-1),currinds(2):(currinds(2)+si(2)-1))=currimg;
    end
    
end
