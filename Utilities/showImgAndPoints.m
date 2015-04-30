function showImgAndPoints(img,pts)

%figure; 

if islogical(img)
    imshow(img);
elseif iscell(img)
    showImg(img);
else
    showImg({img});
end

hold on;
plot(pts(:,1),pts(:,2),'r*');