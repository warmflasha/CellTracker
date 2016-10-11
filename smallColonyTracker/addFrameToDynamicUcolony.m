function colonies = addFrameToDynamicUcolony(mask,mask2,nimg,fimg,framenumber,colonies)
% fill in last entry of dynamicColony array colonies using:
% mask - nuclear mask (only for this colony)
% mask2 - total cell mask (could have other colonies)
% nimg - nuclear image -
% fimg - other fluorescence image

disp([ 'Frame: ' int2str(framenumber)])
discardsmallcyto = 600;
matchdist = 150;
erode_buf = 1;
if ~exist('colonies','var')
    colonies = dynColony();
end

if max(max(mask)) == 0 %nothing to do
    disp('empty mask');
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

%put mask back together
allcytpixel = cat(1,cc2.PixelIdxList);
mask2 = false(size(mask2));
mask2(allcytpixel) = true;

cytfluor = [mean2(nimg(mask2)), mean2(fimg(mask2))];
colonies(end).nucfluor = [colonies(end).nucfluor; nucfluor];
colonies(end).cytfluor = [colonies(end).cytfluor; cytfluor];

%now brake cyt mask into cells and add cytoplasmic fluorescence to each
if length(stats) > 2 %more than 2 cell
    xy = stats2xy(stats);
    vmask = pts2VoronoiMask(xy(:,1),xy(:,2),size(mask)); %voronoi from nuc centers
    cmask = ~vmask & mask2;
elseif length(stats) == 2 % 2 cells, voronoi won't work, use distance transforms
    xy = stats2xy(stats);
    tmp = false(size(mask));
    tmp(xy(1,2),xy(1,1)) = true;
    d1 = bwdist(tmp);
    tmp = false(size(mask));
    tmp(xy(2,2),xy(2,1)) = true;
    d2 = bwdist(tmp);
    cmask = mask2;
    cmask(abs(d1-d2) < 2) = false;
else
    cmask = mask2;
end

cmask = imerode(cmask,strel('disk',erode_buf));
cmask = bwareaopen(cmask,discardsmallcyto,4);
stats2 = regionprops(cmask,fimg,'MeanIntensity','Area','PixelIdxList');


for ii = 1:length(stats)
    done = false;
    pixoverlap = zeros(length(stats2),1);
    for jj = 1:length(stats2)
        pixoverlap(jj) = length(intersect(stats(ii).PixelIdxList,stats2(jj).PixelIdxList));
    end
    [max_ov, ind] = max(pixoverlap);
    
    if max_ov > 0
        nmasknow = false(size(mask));
        nmasknow(stats(ii).PixelIdxList) = true;
        cmasknow = false(size(mask));
        cmasknow(stats2(ind).PixelIdxList) = true;
        cmasknow(imerode(nmasknow,strel('disk',erode_buf))) = false;
        stats(ii).fluordata(end+1) = mean2(fimg(cmasknow));
    else
        stats(ii).fluordata(end+1) = 0; %no data for cyto
    end
end

if ~isempty(colonies(end).onframes)
    %first frame for matching
    ToMatch{1} = [cat(1,stats.Centroid), cat(1,stats.Area), -1*ones(length(stats),1)];
    cells = colonies(end).cells;
    q = 1;
    for ii = 1:length(cells)
        if ~isempty(cells(ii).onframes) && cells(ii).onframes(end) == framenumber-1;
            goodcells(q) = ii;
            q = q + 1;
        end
    end
    if length(cells) > 1
        ncol = size(cells(2).data,2);
    end
    ToMatch{2}=zeros(length(goodcells),ncol);
    for ii = 1:length(goodcells)
        dat = cells(goodcells(ii)).data;
        ToMatch{2}(ii,:) = dat(end,:);
    end
    if length(ToMatch) > 1
        ToMatch = MatchFrames(ToMatch,2,matchdist);
    end
    for ii = 1:size(ToMatch{1},1)
        cellfound = ToMatch{1}(ii,4);
        if cellfound > -1
            colonies(end).cells(goodcells(cellfound))= colonies(end).cells(goodcells(cellfound)).addTimeToCell(stats(ii),framenumber);
        else
            colonies(end).cells(end+1) = dynCell(stats(ii),framenumber);
        end
    end
    
else %
    for ii = 1:length(stats)
        colonies(end).cells(end+1) = dynCell(stats(ii),framenumber);
    end
end
colonies(end).onframes = [colonies(end).onframes; framenumber];
colonies(end).ncells_actual = [colonies(end).ncells_actual; length(stats)];








