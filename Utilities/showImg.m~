function imtouse=showImg(img,sclimits)

if ~exist('sclimits','var')
    sclimits=[0.3 0.99];
end

if length(img)==1
    imtouse=img{1};
    imtouse=imadjust(imtouse,stretchlim(imtouse,sclimits));
else
    si=size(img{1});
    imtouse=uint16(zeros([si 3]));
    for ii=1:3
        if ii<=length(img)
            imtouse(:,:,ii)=imadjust(img{ii},stretchlim(img{ii},sclimits));
        else
            imtouse(:,:,ii)=zeros(size(img{1}));
        end
    end
end
    
imshow(imtouse);
