function [tracks_all] = track_celltypeAN(minpxloverlap,maxdist_tomove,tracks_t0,tr_1,tr_end,tpt_end,tpt,datatomatch)

tracks_all = struct;
if isempty(tr_end)
    tr_end =size(tracks_t0,2);
end
clear overlap
clear overlap_frac
for ii=tr_1:tr_end % size(tracks_t0,2)
    %tracks_t0(ii).coord;
    t = tpt_end;% how many time points to track till (note that tpt-1 and tpt is where the tracks start)
    if size(tracks_t0(ii).coord,1) >1 % only look further at cells that were identified initially as having a cell at the next time point
        tracks_all(ii).coord(1:2,:)= tracks_t0(ii).coord;
        tracks_all(ii).coord(1:2,5)= [1; 2];
        for time = tpt:t-1
            %disp([(time+1)])
            % cellsatt1 = size(datatomatch(time).stats,1);%
            if time == tpt
                tmp0 = tracks_t0(ii).coord(time,1:2);
                tofindcellindx = cat(1,datatomatch(time).stats.Centroid);
                [r,~] = find(tofindcellindx == tmp0);
            end
            %tmp0 = tracks_all(totrack).coord(time,1:2);
            tmp1 = ipdm(tmp0,cat(1,datatomatch(time+1).stats.Centroid),'Subset','NearestNeighbor','Result','Structure');
            %disp(tmp0);
            if tmp1.distance<=maxdist_tomove  %
                closest_cell = tmp1.columnindex;
                % can check for the next closest cell and see if there's
                % one close, than may be a division happened
                closest_cell_dist = tmp1.distance;
                overlap = intersect(datatomatch(time).stats(r(1)).PixelIdxList,datatomatch(time+1).stats(closest_cell).PixelIdxList);
                % determine what percentage of the cell Area at (time+1) is the overlap
                overlap_frac = size(overlap,1)/datatomatch(time+1).stats(closest_cell).Area;
                if overlap_frac>=minpxloverlap
                  %  disp(ii);%match in distance and overlap
                    tracks_all(ii).coord(time+1,1:2) = cat(1,datatomatch(time+1).stats(closest_cell).Centroid);
                    tracks_all(ii).coord(time+1,3)=overlap_frac;
                    tracks_all(ii).coord(time+1,4)=closest_cell_dist;
                    tracks_all(ii).coord(time+1,5)=time+1;
                    tmp0 = tracks_all(ii).coord(time+1,1:2);
                    tofindcellindx = cat(1,datatomatch(time+1).stats.Centroid);%
                    [r,~] = find(tofindcellindx == tmp0);
                end
                if size(overlap,1)<minpxloverlap
                   % disp('match in distance ,no match in overlap');
                    %disp(size(overlap,1));
                    %tmp0 = tracks_all(totrack).coord(time+1,1:2);
                end
            end
            if tmp1.distance>maxdist_tomove
                % disp('no close match found');
                %tmp0 = tracks_all(totrack).coord(time,1:2);
                continue
            end
            
        end% time loop
    end
end
end