function img_out=smoothImage(img,rad,sig,filt_type)
%apply gaussian filter with radius rad and std sig to an image

if ~exist('filt_type','var')
    filt_type = 'gaussian';
end

filt = fspecial(filt_type,rad,sig);
img_out=imfilter(img,filt);