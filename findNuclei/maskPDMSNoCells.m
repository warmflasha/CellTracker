function mask = maskPDMSNoCells(img)
%
%   mask = maskPDMSNoCells(img, filter)
% 
%   filter = 1 do gaussian filter on image, =0 skip
%   ALgorithm, thresholds the image assuming there is a local minimum in the
% intensity histogram dividing the PDMS intensity from the media intensity peak. Some buried params in
% thresh_in_PDMS() function put limits on the area fraction that can be PDMS
%   Size of inlet PDMS bars is about 80 pixels in full size image.
%

global userParam

filter=1;
if filter
    gauss_r = userParam.gaussFilterRadius;
    hg = fspecial('gaussian', 6*gauss_r, gauss_r);
    img = imfilter(img, hg, 'replicate');
end

% cut out +- this region around center to find posts and threshold separatedly
[m,n] = size(img);
half = min(size(img))/4;
rows = (m/2-half):(m/2+half);
cols = (n/2-half):(n/2+half);

% expand thresholded mask by this number of pixels in all directions
pix_dilate = round(5*min(size(img))/1024);

mask = false(size(img));
ctr = img( rows, cols );  % save for next block of code

% saturate the central square to eliminate it from thresholding
maxI = max(img(:));
img(rows, cols) = maxI;
thresh2 = thresh2PeakHist(img, [0.03, 0.20] );

if isempty(thresh2)
    fprintf(1, 'WARNING maskPDMSNoCells(): could not find plausible intensity threshold for PDMS boundaries, skipping\n');
else
    mask = (img < thresh2);
end

% after assign boundaries of PDMS to mask find central posts
thresh1 = thresh2PeakHist(ctr, [0.01, 0.1] );

if isempty(thresh1)
    fprintf(1, 'WARNING maskPDMSNoCells(): could not find plausible intensity threshold for posts in center of img, skipping\n');
else
    % could check that get >2 <= 4 posts 
    mask(rows, cols) = (ctr < thresh1);
end

mask = imerode(mask, strel('square', 3));    % remove isolated pixels
% smooth out
mask = imdilate(mask, strel('square', 2*pix_dilate+1) );
% mask = imerode(mask, strel('square', 2*pix_dilate+1) );

return