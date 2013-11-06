function cleaned=filterAndBGsub(inputImage,smoothp,backdisk)
%function cleaned=cleanImage(inputImage,smoothradius,smoothsigma,backdisk)'
%------------------------------------------------------------
%Function to gaussian filter and background subtract an image

gaussfilt=fspecial('gaussian',smoothp(1),smoothp(2));
image_f=imfilter(inputImage,gaussfilt);
bg=imopen(image_f,strel('disk',backdisk));
cleaned=imsubtract(image_f,bg);