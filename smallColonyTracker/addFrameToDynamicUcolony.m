function colonies = addFrameToDynamicUcolony(mask,mask2,nimg,fimg,framenumber,colonies)
% fill in last entry of dynamicColony array colonies using:
% mask - nuclear mask (only for this colony)
% mask2 - total cell mask (could have other colonies)
% nimg - nuclear image -
% fimg - other fluorescence image

matchdist = 150;
erode_buf = 1;
if ~exist('colonies','var')
    colonies = dynColony();
end

if max(max(mask)) %nothing to do
    return;
end

%get the nuclear stats
stats = regionprops(mask,nimg,'Centroid','Area','MeanIntensity','PixelIdxList');
stats2 = regionprops(mask,fimg,'MeanIntensity');
for ii = 1:length(stats)
    stats(ii).fluordata = [stats(ii).MeanIntensity, stats2(ii).MeanIntensity];
end

%total nuclear mean
allnucpixels = cat(1,stats.PixelIdxList);
nucfluor = [mean(nimg(allnucpixels)), mean(fimg(allnucpixels))];

%for cytoplasmic fluor, first restrict cytomask to those that contain nuclei
% from this colony
cc2 = regionprops(mask2,'PixelIdxList');

toremove = false(length(cc2),1);
for ii = 1:length(cc2)
    if isempty(intersect(cc2(ii).PixelIdxList,allnucpixels))
        toremove(ii) = true;
    end
end
cc2(toremove) = [];

%put mask back together and remove nuclei
allcytpixel = cat(1,cc2.PixelIdxList);
mask2 = false(size(mask2));
mask2(allcytpixel) = true;
mask2(imerode(mask,strel('disk',erode_buf))) = false; %remove nuclei

cytfluor = [mean2(nimg(mask2)), mean2(fimg(mask2))];
colonies(end).nucfluor = nucfluor;
colonies(end).cytfluor = cytfluor;

if ~isempty(colonies(end).onframes)
    %first frame for matching
    ToMatch{1} = [cat(1,stats.Centroid), cat(1,stats.Area), -1*ones(length(stats),1)];
    cells = colonies(end).cells;
    q = 1;
    for ii = 1:length(cells)
        if ~isempty(cells(ii).onframes) && cells(ii).onframes(end) == framenumber-1;
            dat = cells(ii).data;
            ToMatch{2}(q,:) = dat(end,:);
            q = q + 1;
        end
    end
    if length(ToMatch) > 1
    ToMatch = MatchFrames(ToMatch,2,matchdist);
    end
    for ii = 1:size(ToMatch{1},1)
        cellfound = ToMatch{1}(ii,4);
        if cellfound > -1
            colonies(end).cells(cellfound).addTimeToCell(stats(ii),framenumber);
        else
            colonies(end).cells(end+1) = dynCell(stats(ii),framenumber);
        end
    end
    
else %
    for ii = 1:length(stats)
        colonies(end).cells(end+1) = dynCell(stats(ii),framenumber);
    end
end
colonies(end).onframes(end+1) = framenumber;








