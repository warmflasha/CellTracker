function dispCCC(red, green, ph)
%
%   dispCCC(red, green, ph)
%
% make nicely scaled image of CCC output, Use [] for any image to skip

gs = 0;
blank = [];
if ~isempty(ph)
    gs = 0.;
    s_ph = imadjust(ph, stretchlim(ph), [0, 1]);
    blank = uint16(zeros(size(ph)));
end
if ~isempty(red)
    s_red = imadjust(red, stretchlim(red), [0, 1-gs]);
    if isempty(blank)
        blank = uint16(zeros(size(red)));
    end
end
if ~isempty(green)
    s_gr = imadjust(green, stretchlim(green), [0, 1-gs]);
end

img = cat(3, s_red, s_gr, blank);
if(min(size(red)) >= 1024 )
    img = imresize(img, 0.5, 'nearest');
end
%hg = fspecial('gaussian', 12, 2); % should not have to change this value
%img = imfilter(img, hg, 'replicate');
if ~isempty(ph)
    figure
    subplot(1,2,1), subimage(img)
    subplot(1,2,2), subimage(s_ph);
    %img = cat(3, s_red+s_ph, s_gr+s_ph, s_ph);
else
    figure, imshow(img)
end

return 
