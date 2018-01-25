function [coloniesintime,lbl_mask] = assigncellstosamecolonyintime(dilmask,pos,matfile,paramfile,tpts)
clear coloniesintime
     lbl_mask = [];
% first the colony assignment is determened nd set for the first time point
% the the same mask is used to assign the rest of cells  to the same colony (defined by its dilated mask)
load(matfile,'positions');
run(paramfile)
jj = pos;
ti = 1;
bg = positions(pos).timeTraces.background;%
rmbg = ones(size(positions(jj).cellData(ti).nucLevel))*bg(ti);% get bg vector; it is different for each time point
nuctocyto = (positions(jj).cellData(ti).nucLevel(:,1)-rmbg)./(positions(jj).cellData(ti).cytLevel(:,1)-rmbg); % subtrct bg from nuc and cyto green levels
cellcoord = positions(jj).cellData(ti).XY;
[groupids]= NewColoniesAW(cellcoord);
XYandcolonyID = cat(2,cellcoord,groupids,nuctocyto);
colids(ti).intime = unique(groupids);
% group the xydata by colony id into structue separatecol
for k=1:size(colids(ti).intime,1) % loop over colonies in the image
    tmp = find(XYandcolonyID(:,3)==colids(ti).intime(k));
    separatecol(k).dat = XYandcolonyID(tmp,1:4);
    separatecol(k).signal = XYandcolonyID(tmp,4);
    colcenter(ti).coord(k,1:3) = [round(mean(separatecol(k).dat(:,1))),round(mean(separatecol(k).dat(:,2))) separatecol(k).dat(1,3)];
    colsignal(ti).dat(1:size(separatecol(k).signal,1),k) = separatecol(k).signal; % the column number here is the original label for the colony ID
end
% assign the pixelID value of each colony (that will be kept the same throughout time)
% this needs to be done only once (get it out of the time
% loop)
fullcolstat = regionprops(dilmask,'Centroid','PixelIdxList');
grouping_centroids = colcenter(ti).coord;% at the tp = 1
dilmask2 = zeros(size(dilmask));
for j = 1:size(fullcolstat,1)
    for k=1:size(grouping_centroids,1)
        if  intersect(sub2ind(size(dilmask),grouping_centroids(k,2),grouping_centroids(k,1)),fullcolstat(j).PixelIdxList) %grouping_centroids(k,1:2)
            dilmask2(fullcolstat(j).PixelIdxList) = grouping_centroids(k,3);
        end
    end
end
% figure(2),imshow(dilmask2,[]); hold on
calibratedmask = regionprops(dilmask2,'Centroid','PixelIdxList');
% use dilmask2 to group the cells belonging to the same colony

% loop through the rest of time points
colonies_alltimes = struct;%cell(tpts,1);
for h=1:tpts %
    rmbg = ones(size(positions(jj).cellData(h).nucLevel))*bg(h);% get bg vector; it is different for each time point
    
    nuctocyto = (positions(jj).cellData(h).nucLevel(:,1)-rmbg)./(positions(jj).cellData(h).cytLevel(:,1)-rmbg); % subtrct bg from nuc and cyto green levels
    cellcoord = round(positions(jj).cellData(h).XY);% all cells at a given time point
    % find the intersection of all the cells with each colony mask
    % (specific pixelIDXs)
    % and assign cell group ID bsed on that
    celltocolonies = struct;
    for l=1:size(cellcoord,1)
        for k=1:size(calibratedmask,1)
            tmp = intersect(sub2ind(size(dilmask),cellcoord(l,2),cellcoord(l,1)),calibratedmask(k).PixelIdxList); % sub2ind(size(dilmask),cellcoord(:,2),cellcoord(:,1)) see which cells belong to which PixelIdxList
            if ~isempty(tmp)
                celltocolonies(k).data(l,1:2) =  cellcoord(l,1:2);
                celltocolonies(k).data(l,3) =  nuctocyto(l);
                
            end
        end
    end
    % store the celltocolonies structi=ure at each time point
    colonies_alltimes(h).alltimes = celltocolonies;
    
end
lbl_mask = dilmask2;
coloniesintime = colonies_alltimes;
end