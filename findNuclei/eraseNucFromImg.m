function img = eraseNucFromImg(img)
%
%  img = eraseNucFromImg(img, stats)
%
% For an image with nuclei defined via stats array, approx each nuclei by a
% ellipsoidal cone and subtract. So as to reveal additional local max in
% output array. For purposes of subtraction, approx the nuclear intensity
% as having a max at geometric center of nuc mask, and values on the edge
% of nuc mask = min(imgIn in nucleus). 
%   intensity to be subtracted = cst - cst * (x*x + x*y + y*y) (or 0)
%
pixels = find(img>350);
bckgnd = img(end:end)
img2 = 350;
img1 = max(img(:));

[ctr, qform] = mask2ellipse(size(img), pixels);

return

function [ctr, qform] = mask2ellipse(sizei, pixels)
% take pixels and return center and coef for ellipse such that
%   nuc mask ~ (c1*x^2 + c2*x*y + c3*y^2)<=1. Ctr is given as x,y

[row, col] = ind2sub(sizei, pixels);
ctr = round([mean(col), mean(row)]);
mtx = cov(row, col);
% interchange 1,2 since want coef of xx and xy and yy
qform = [mtx(1,1), -2*mtx(1,2), mtx(2,2)];
% be sure quad form is + definite.
if abs(qform(2)) > 2*sqrt(qform(1)*qform(3))
    qform(2) = sign(qform(2))*2*sqrt(qform(1)*qform(3));
end
det = mtx(1,1)*mtx(2,2) - mtx(1,2)^2;
% area of qform is det(mtx), rescale by number of pixels
qform = qform*pi/(sqrt(det)*length(pixels));
% area within qform ==1 is ~length(pixels)
return

function cone = parabaloid(img1, img2, bckgnd, qform)
% value of cone around perimeter of nuclear mask is ~img2, max cone = img1
% should limit cone to max(cone, bckgnd)

scl = double(img1 - bckgnd)/double(img1 - img2);
disc = 4*qform(1)*qform(3) - qform(2)^2;
xlim = ceil( sqrt(double(scl*4*qform(3)/disc)) );
ylim = ceil( sqrt(double(scl*4*qform(1)/disc)) );

m = round(2*ylim) + 1;
n = round(2*xlim) + 1;
m0 = ylim + 1;
n0 = xlim + 1;
cone = zeros(m,n);
for i = 1:m
    for j = 1:n
        cone(i,j) = img1 - (img1 - img2)*( qform(3)*(i-m0)^2 + qform(1)*(j-n0)^2 + qform(2)*(i-m0)*(j-n0) );
    end
end

return
        