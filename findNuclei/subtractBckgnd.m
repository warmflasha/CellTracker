function [im1, bckgnd] = subtractBckgnd(im0)
% remove a slowly varying background from intensity image so as to isolate
% 'nuclei of some typical size. 
%   input image = im1 + bckgnd
% but a choice of zero level is made such that the variance of im1 outside
% the nuclei is preserved, which assists in computing threshold for nuclear
% mask.

global userParam

% this parameter should be a guess for area of a large but single nuclei.
% May revert to nucAreaHi.

nucAreaBckgnd = 100;

% filter a bit first to remove extreme local min, which otherwise will
% cause holes around large bright objects after imclose
hg = fspecial('gaussian', 12, 2);
bckgnd = imfilter(im0, hg, 'replicate');

rdisk = ceil(sqrt(userParam.nucAreaBckgnd/pi));
% remove the nuclei from image before filtering.
bckgnd = imclose(bckgnd, strel('square', 2*rdisk+1));
hg = fspecial('gaussian', 12*rdisk, 2*rdisk);
bckgnd = imfilter(bckgnd, hg, 'replicate');
mm = min(bckgnd(:));
bckgnd = bckgnd - mm;
im1 = im0 - bckgnd;