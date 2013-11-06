function setUserParamDish10x()

global userParam

userParam.filter = fspecial('gaussian', 12, 2);
userParam.nucAreaLo =10; %not too small
userParam.nucAreaHi = 200;

userParam.verboseCountNuc = 1;  % to print statistics and an image
userParam.V2008a = 0;
% Filter for acceptable nuclei: 
%   intensity_at_max >= (average intensity in annulus defined by
%   radiusMin/Max) + nucIntensityRange
% nuclei within rmax of boundary of image are not excluded.
%
userParam.radiusMin = 2;
userParam.radiusMax = 3;
userParam.nucIntensityRange = 3;
userParam.nucIntensityLoc   = 2;
