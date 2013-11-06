function plotFrameMatch(peaks,frame,imgfiles,usehisteq)
% 
% Graph of map of nuc centers from frame-1 to frame (>=2)
% set usehisteq=1 to use the histeq function to stretch histogram
%otherwise set to 0 to show raw images.

if ~exist('usehisteq','var')
    usehisteq=1;
end

img1=im2double(imread(imgfiles(frame-1).nucfile));
img2=im2double(imread(imgfiles(frame).nucfile));

if usehisteq
img1=histeq(img1); img2=histeq(img2);
end

overlay=cat(3,img1,img2,zeros(size(img1)));
rmax=max(max(img1)); rmin=min(min(img1));
gmax=max(max(img2)); gmin=min(min(img2));
overlay2=imadjust(overlay,[rmin gmin 0; 2/3*rmax 2/3*gmax 1]);

imshow(overlay2,[]); hold on;
%figure; hold on;

xy0 = peaks{frame-1}(:, 1:2);
target = peaks{frame-1}(:, 4);
xy1 = peaks{frame}(:, 1:2);

%figure
%hold on
plot(xy0(:,1), xy0(:,2), '.r');
plot(xy1(:,1), xy1(:,2), '.g');
for i = 1:length(target)
    tt = target(i);
    if(tt < 0 )
        continue
    end
    plot([xy0(i,1), xy1(tt,1)], [xy0(i,2), xy1(tt,2)], '-k' );
end

nomatch0 = length(find(target<0));
nomatch1 = length(xy1) - (length(xy0) - nomatch0);
title(['r,g=frame',num2str([frame-1, frame]), ', r no match=',num2str(nomatch0), ', g no match=',num2str(nomatch1)]);
hold off
