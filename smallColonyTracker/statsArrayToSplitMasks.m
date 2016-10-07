function out_masks = statsArrayToSplitMasks(stats,imsize)
medfiltsize = 11;
maxeroderad = 50;
ntimes = length(stats);
ncellsperframe = cellfun(@(x)size(x,1),stats);
ncells = sum(cellfun(@length,stats));

%get all xyt data
xyt = zeros(ncells,3);
q = 1;
for ii = 1:ntimes
    xyt(q:(q+ncellsperframe(ii)-1),1:2) = cat(1,stats{ii}.Centroid);
    xyt(q:(q+ncellsperframe(ii)-1),3) = ii; %time number
    xyt(q:(q+ncellsperframe(ii)-1),4) =1:ncellsperframe(ii); %cell number within that frame
    xyt(q:(q+ncellsperframe(ii)-1),5) =cat(1,stats{ii}.Area); %areas
    q = q + ncellsperframe(ii);
end

%group into colonies
global userParam;
userParam.colonygrouping = 100;
allinds=NewColoniesAW(xyt(:,1:2));
xyti = [xyt,allinds];



ncolonies = max(allinds);

figure; plot(xyt(:,1),xyt(:,2),'r.'); hold on;
for ii = 1:ncolonies
    coldata = xyti(allinds == ii,:);
    mm  = mean(coldata,1);
    text(mm(1),mm(2),int2str(ii),'Color','c');
end


for ii = 1:ncolonies %loop over colonies, find the ones that need to be split
    coldata = xyti(allinds == ii,:);
    nc_time =zeros(ntimes,1);
    nc_area = nc_time;
    for jj = 1:ntimes
        curr_inds = coldata(:,3) == jj;
        nc_time(jj) = sum(curr_inds); %number of cells in colony
        nc_area(jj) = sum(coldata(curr_inds,5)); %colony area
    end
    nc_time_f = medfilt1(nc_time,medfiltsize);
    needspliting1 = find(nc_time < nc_time_f & nc_time > 0); % goes down and back up
    %nc_time(nc_time > nc_time_f) = nc_time_f(nc_time > nc_time_f);
    cmax = cummax(nc_time);
    needspliting2 = find(nc_time > 0 & nc_time < cmax & nc_area > 1.05*cummin(nc_area)); %down from max but not smaller
    correctcell1 = nc_time_f(needspliting1);
    correctcell2 = cmax(needspliting2);
    [needspliting{ii}, inds] = unique([needspliting1; needspliting2]);
    correctcell_num{ii} = [correctcell1; correctcell2];
    correctcell_num{ii} = correctcell_num{ii}(inds);
end

for ii=1:ntimes % loop over time and put
    mask = false(imsize);
    disp(['Time: ' int2str(ii)]);
    for jj = 1:ncolonies
        inds = xyti(:,6) == jj & xyti(:,3) == ii; %correct colony and time
        cellnums = xyti(inds,4);
        tmpmask = false(imsize);
        tmpmask(cat(1,stats{ii}(cellnums).PixelIdxList))=true;
        if ismember(ii,needspliting{jj}) % if colony needs to be split
            numneeded = correctcell_num{jj}(needspliting{jj}==ii);
            cc = bwconncomp(tmpmask);
            ncell = cc.NumObjects;
            erode_rad = 1;
            while ncell < numneeded && erode_rad < maxeroderad
                newmask = imerode(tmpmask,strel('disk',erode_rad));
                cc = bwconncomp(newmask);
                ncell = cc.NumObjects;
                erode_rad = erode_rad + 1;
                
            end
            if erode_rad == maxeroderad
                disp(['Warning: Failed to split. Colony ' int2str(jj) ' time ' int2str(ii)]);
                maskToUse = tmpmask;
            else
                disp(['Split: Colony ' int2str(jj) ' time ' int2str(ii) '. Erode radius: ' int2str(erode_rad)]);
                
                outside = ~imdilate(tmpmask,strel('disk',1));
                basin = imcomplement(bwdist(outside));
                basin = imimposemin(basin, newmask | outside);
                
                L = watershed(basin);
                maskToUse = L > 1;
            end
        else
            maskToUse  = tmpmask;
        end
        mask = mask | maskToUse;
    end
    out_masks(:,:,ii) = mask;
end
