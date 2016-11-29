function [ img ] = presubBackground_provided( img,nucOrSmad )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

global userParam;

if nucOrSmad == 1;
    
    bg_nuc = imread('bg_nuc.tif');
    bg_nuc = smoothImage(bg_nuc,userParam.backgroundSmoothRad,userParam.backgroundSmoothSig);
    img=imsubtract(img,bg_nuc);
    
    
elseif nucOrSmad == 2;
    bg_fimg = imread('bg_fimg1.tif');
    bg_fimg = smoothImage(bg_fimg,userParam.backgroundSmoothRad,userParam.backgroundSmoothSig);
    img=imsubtract(img,bg_fimg);
end
end


