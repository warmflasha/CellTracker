function mask = maskPDMS(img)
%
%   mask = maskPDMS(img)
% 
% Given a CCC green image with lower background in entry channels where PDMS
% blocks the medium, compute a mask = 1 in PDMS and 0 in medium.
%   ALgorithm, thresholds the image assuming there is a local minimum in the
% intensity histogram dividing the PDMS from the medium. Some buried params in
% thresh_in_PDMS() function put limits on the area fraction that can be PDMS
%   Size of inlet PDMS bars is about 80 pixels in full size image.
%

% expand thresholded mask by this number of pixels in all directions
pix_dilate = round(20*min(size(img))/1024);

thresh = thresh_in_PDMS(img);
mask = img < thresh;
mask = imopen(mask, strel('square', 3));    % remove isolated pixels
mask = imdilate(mask, strel('square', 2*pix_dilate+1) );

function thresh = thresh_in_PDMS(img)
% Fit several histogram pts to a + b*i^2 and insist b>0 to find local min in
% distribution.

% min/max allowed PDMS area
prob1 = 0.04;   prob2 = 0.2;

% bins in histogram from min to max intensity.
nbin = 256;

% compute a second deriv by fitting 2*band+1 bins of histogram
band = 2; 

maxI = max(img(:));
scl = floor((2^16-1)/maxI );
[cts, bins] = imhist(scl*img, nbin);

wt = sum(cts(1:band));
totwt = numel(img);
minerr = totwt;
thresh = [];
for ii = (1+band):(nbin-band)
    wt = wt + cts(ii);
    if( wt/totwt < prob1 )
        continue
    end
    if( wt/totwt > prob2 )
        break
    end
    data = cts((ii-band):(ii+band));
    data = data - min(data);
    pts = -band:band;
    [poly, struct] = polyfit(pts', data,2);
    error = struct.normr;
    % more elaborate tests here might decide if no local min, ie test linear
    % term in fit.
    if(error < minerr && poly(1) > 0 )
        thresh = round(bins(ii)/scl);
        minerr = error;
    end
    fprintf(1, 'ii= %d, frac wt= %d, poly= %d %d %d, error= %d\n',ii, wt/totwt, poly, error);
end

return
%% k means does not work
% ctr1 = bins(i2);  ctr2 = bins(i2);
% for iter = 1:100
%     mid = round( (ctr1 + ctr2)/(2*bins2int) );
%     ctr1 = dot( bins(1:mid), cts(1:mid) )/sum(cts(1:mid));
%     ctr2 = dot( bins((mid+1):end), cts((mid+1):end) )/sum(cts((mid+1):end));
%     [ctr1, ctr2]
%     [sum(cts(1:mid)), sum(cts((mid+1):end))]/prod(size(img))
% end
% return