function e_img = sobelEdge(img)
%apply sobel edge filter to an image


hx = fspecial('sobel');
hy = hx';

Iy = imfilter(double(img), hy, 'replicate');
Ix = imfilter(double(img), hx, 'replicate');
e_img = sqrt(Ix.^2 + Iy.^2);

