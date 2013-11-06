function img2 = erase_nuc(img, mask)

nucIntensityLoc = 5;
mask2 = img + nucIntensityLoc;
im3 = imreconstruct(img, mask2);
regmx = mask2 - im3;
regmx = (regmx >= nucIntensityLoc - 1);
[row, col] = find(regmx);
%row', col'

% mask = imdilate(mask, strel('square', 5));
% dst = bwdist(~mask);
% fac = exp(-3* dst);
% img2 = double(img).*fac;
% img2 = uint16(img2);
mask = false(size(img));
mask(26,34) = 1;
dst = double(bwdist(mask));
cone = max(760 - dst.^2, 150);

%cone = make_cone(img);
img2 = img - uint16(cone);

mask2 = img2 + nucIntensityLoc;
im3 = imreconstruct(img2, mask2);
regmx = mask2 - im3;
regmx = (regmx >= nucIntensityLoc - 1);
figure, imshow(regmx)
figure, imshow(img2, [])
[row, col] = find(regmx);
row', col'

return

function cone = make_cone(img)
cone = zeros(size(img));

[m,n] = size(img);
for i = 1:m
    for j = 1:n
        dst = (i-26)^2 + (j-34)^2;
        cone(i,j) = 782 - dst*(274/15^2);
    end
end
cone = max(cone, 0);
cone = uint16(cone);