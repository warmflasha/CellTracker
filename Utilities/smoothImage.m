function img_out=smoothImage(img,rad,sig)
%apply gaussian filter with radius rad and std sig to an image

filt = fspecial('gaussian',rad,sig);
img_out=imfilter(img,filt);