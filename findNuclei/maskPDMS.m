function mask = maskPDMS(img)
%
%   mask = maskPDMS(img)
% 
% Given a CCC green image with lower background in entry channels where PDMS
% blocks the medium, compute a mask = 1 in PDMS and 0 in medium.
%  
%   ALgorithm, thresholds the image assuming there is a local minimum in the
% intensity histogram dividing the PDMS intensity from the media intensity peak. Some buried params in
% thresh_in_PDMS() function put limits on the area fraction that can be PDMS
%   Size of inlet PDMS bars is about 80 pixels in full size image.
%

% if filter
%     gauss_r = userParam.gaussFilterRadius;
%     hg = fspecial('gaussian', 6*gauss_r, gauss_r);
%     img = imfilter(img, hg, 'replicate');
% end

% expand thresholded mask by this number of pixels in all directions
pix_dilate = round(5*min(size(img))/1024);

thresh = thresh2PeakHist(img, [0.04, 0.2] );
if isempty(thresh)
    fprintf(1, 'WARNING,maskPDMS(): could not find plausible intensity threshold, returning mask==0\n');
    mask = false(size(img));
    return
end
mask = img < thresh;
mask = imopen(mask, strel('square', 3));    % remove isolated pixels
mask = imdilate(mask, strel('square', 2*pix_dilate+1) );

return