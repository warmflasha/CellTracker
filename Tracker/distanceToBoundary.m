function d2b=distanceToBoundary(imsize,positions)
%given image size and positions, compute distance to boundary
%imsize could be 2 component vector with the size of the image or else
% a mask (for more complex situations).


%make an image, zeros everywhere, ones on boundary
if length(imsize) == 2
    img=zeros(imsize(2)+2,imsize(1)+2);
    img(end,:)=1;
    img(:,end)=1;
    img(1,:)=1;
    img(:,1)=1;
else
    img = imsize;
end

%use dist transform to get dist to boundary
distt=bwdist(img);

%look up dist to boundary for each cell
d2b=zeros(length(positions),1);
for ii=1:length(positions)
    d2b(ii)=distt(positions(ii,1)+1,positions(ii,2)+1);
end

