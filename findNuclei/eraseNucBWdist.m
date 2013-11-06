function img2 = eraseNucBWdist(img, stats)
% this does not work, have to subtract actual max for each nucl (which can
% be done via imdilate(image with max at center of nuc only), but probably
% still need to approx each nuc area to properly subtract.

global userParam

xy = stats2xy(stats);
mask = false(size(img));
pix = sub2ind(size(img), xy(:,2), xy(:,1));
mask(pix) = 1;
dst = bwdist(mask);
dst = dst.^2;

hi = double(median(img(pix)) );
lo = 150;       % background value
rsq_nuc = sqrt(userParam.nucAreaLo*userParam.nucAreaHi)/pi;

cones = hi - (hi - lo)*dst/rsq_nuc;
cones = uint16(max(cones, lo));

img2 = img - cones;

return