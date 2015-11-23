% cut the stitched image coming from CellSense and name each file according
% to uManager naming convention
function UnstichingImageAN(imagefromcellsense,griddimensions,magnigication)
I = imread('test2dapi20x.tif');
dims = [input1, inpit2]; % input arguments, known from when setting up the grid ( mainly to faster determine which direction has how many images
s1 = size(I,1);
s2 = size(I,2);

mag = [2048,2048]; % also input parameter

dim2 = s1/mag(2); %rows, in the y direction
dim2 = round(s1/mag(2));

dim1 = s2/mag(1); % cols, in the x direction
dim1 = round(s2/mag(1));

for j = 1:dim1         % here need to set up correctly how the matrix will be subdevided into images (j and i ) and also code them into the name of the resulting position
    for k = 1 % only look at the first column of images
     
pos{j} = I(2048*(j-1):(2048*(j)),(2048)*(k-1):(2048*(k)));
           
end
%save(['CellTraces_' num2str(N) ],'datcell');