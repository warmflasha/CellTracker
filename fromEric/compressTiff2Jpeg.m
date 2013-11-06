function img = compressTiff2Jpeg(img, mask, toler, verbose)

% Take an image = img (eg tiff) with an optional mask for the regions to be retained
% and wrte a variable quality jpg image to fullPathName/img.jpeg.
% NOT FINISHED, CAN CAUSE PROBLEMS WITH GLUING IMAGES
%   
% Best option for compression is 12bit jpeg with regions outside of mask
% set to 0 (or any cst)
%
%   mask = 1 in regions to be retained, [] if use whole image.
%   
%   toler = fraction of pixels on hi end that can be capped if needed to keep
%           image within bitsJpeg. Should be <= 0.001
%

bitsJpeg  = 12;
rangeJpeg = 2^bitsJpeg-1;
qualityJpeg = 75;   % see imwrite, and other options at end of routine

if  isa(img, 'uint16')
    maxRangeClass = 2^16 - 1;
elseif isa(img, 'uint8')
    maxRangeClass = 2^8 - 1;
else
    error('unknown image class input to compressTiff2Jpeg aborting!\n');
end

if ~isempty(mask)
    noncolony = mean(img(~mask));
    img(~mask) = noncolony;
    img = img(mask);
else
    noncolony = [];
end
maxi = max(max(img));

% 
if maxi > rangeJpeg
    limits = maxRangeClass * stretchlim(img, toler);
    % if image in range after omitting fraction=toler pixels do so.
    if limits(2) <= rangeJpeg
        img = min(img, rangeJpeg);
        msg1 = sprintf('limited img to %d', rangeJpeg);
    % if lower limit is appreciable, subtract it
    elseif limits(1) >= (rangeJpeg + 1)/4
        img = imsubtract(img, limits(1));
        if limits(2) - limits(1) <= rangeJpeg
            img = min(img, 2^bitsJpeg-1);
        else    % resclae image if upper limit too large to fit
            scl = rangeJpeg/double( limits(2) - limits(1) );
            img = scl*img;
        end
    % otherwise rescale to keep image in range, but do not subtract,  since not
    % much to gain
    elseif limits(2) > rangeJpeg
        scl = rangeJpeg/double(limits(2));
        img = scl*img;
    else
    end
else
    msg = sprintf('converted img to %d bit jpeg, quality= %d', bitJpeg, qualityJpeg);
end

% [path, name, exten] = fileparts(fullPathName);
% jpegName = fullfile(path, strcat(name, '.jpeg') );

fprintf(1, 'After saturating %d percent (lo/hi), limits of phase image= %d %d, mapped to 0, %d\n', ...
    100*toler, limits, 2^bitsJpeg - 1);
scl = (2^bitsJpeg - 1)/double( limits(2) - limits(1) );
jpeg = uint16( (double(img) - limits(1)) * scl );
%imwrite(img, jpegName, 'Bitdepth', 16 , 'Mode', 'lossless');
imwrite(jpeg, jpegName, 'Bitdepth', bitsJpeg, 'Quality', qualityJpeg);
