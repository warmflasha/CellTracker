function [ output_args ] = checkSegmentation( position,hourPostLigand,channel )
%checkSegmentation displays the corresponding image for a given position
%and time
%   for now does not work with image files containing more than 3 dims and
%   only supports 2 channel images
%   (e.g.,single position time or z stack, but not both)
% CURRENTLY BROKEN / INCOMPLETE
files = readAndorDirectory(analysisParam.imgDirec);

imgName = dir([analysisParam.imgDirec filesep files.prefix '_f*' int2str(position) '.tif']);
img = bfopen([analysisParam.imgDirec filesep imgName.name]);
peaks = load([analysisParam.outDirec filesep 'pos' int2str(position) '.mat'],'peaks');
peaks = peaks.peaks;
timepoint = find(analysisParam.plotX==hourPostLigand);
if channel ==1;

figure; hold on; 
imshow(img{1}{timepoint*2,1},[]); hold on;
plot(peaks{timepoint}(1,:),peaks{timepoint}(2,:),'*');
elseif channel ==2
        figure; imshow(img{1}{timepoint*2+1,1},[]); hold on;
        plot(peaks{timepoint}(1,:),peaks{timepoint}(2,:),'*');
end

