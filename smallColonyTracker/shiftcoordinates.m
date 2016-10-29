function shifted = shiftcoordinates(dat,fr_stim,imsize)
sz = imsize;
curr1 = [dat{fr_stim-1}.Centroid];
x1 = curr1(1:2:end);% x coordinated of s1 cells before shift
y1 = curr1(2:2:end);% y coordinated of s1 cells before shift

curr2 = [dat{fr_stim+1}.Centroid];
x2 = curr2(1:2:end);% x coordinated of s2 cells after shift
y2 = curr2(2:2:end);% y coordinated of s2 cells after shift


diffx = sqrt(power(x1(1)-x2(1),2));
diffy = sqrt(power(y1(1)-y2(1),2));
shift = round([diffx,diffy]);

dat{fr_stim} = dat{fr_stim-1};% since at the shift tpt, the cells are completely different, reassign the cells in that frame to the ones in the frame before, to avoid loosing track
% now need to shift the xy coordinates of cells in each frame after
% shiftframe and put them back into the stats.Centroid structure
for k=fr_stim+1:size(dat,2)
   if ~isempty(dat{k})
        s = size(dat{k},1);                         % get the number of cells in this time point
        toshiftcurr = [dat{k}.Centroid];
        x = toshiftcurr(1:2:end);                   % x coordinated of cells in current frame
        y = toshiftcurr(2:2:end);                   % y coordinated of cells in current frame
        xy = cat(2,x',y');                          % make a matrix from the coordinates
        xyshifted = bsxfun(@plus,xy,shift);         % shift xy coordinates
        if any(xyshifted(:,1) > sz(1)) || any(xyshifted(:,1) > sz(2))% if the shift moves the cellout of the frame zero the cell coordinates
           xyshifted = zeros(size(xyshifted));
        end
        for jj=1:s                                   % if not, then put the shifted coordinates back into the Centroid structure
        dat{k}(jj).Centroid = xyshifted(jj,:);
        end
        
    end
end
shifted = dat;                                       % return the structure with shifted centroids after shiftframe
end



