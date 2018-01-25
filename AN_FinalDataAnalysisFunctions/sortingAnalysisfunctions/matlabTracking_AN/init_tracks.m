function [tracks_t0] = init_tracks(minpxloverlap,maxdist_tomove,datatomatch,tpt)
clear tmp1
tracks_t0 = struct;
q = 1;
%tpt = 2;
for time = 1:tpt-1    
    cellsatt1 = size(datatomatch(time).stats,1);%
        for jj=1:cellsatt1 
              tracks_t0(q).coord(time,1:2) = cat(1,datatomatch(time).stats(jj).Centroid);
              tmp1 = ipdm(tracks_t0(q).coord(time,1:2),cat(1,datatomatch(time+1).stats.Centroid),'Subset','NearestNeighbor','Result','Structure');
            if tmp1.distance<=maxdist_tomove  % todo: add condition on the overlap size here
                closest_cell = tmp1.columnindex;
                % can check for the next closest cell and see if there's
                % one close, than may be a division happened
                closest_cell_dist = tmp1.distance;
                overlap = intersect(datatomatch(time).stats(jj).PixelIdxList,datatomatch(time+1).stats(closest_cell).PixelIdxList);
                % determine what percentage of the cell Area at (time+1) is the overlap
                overlap_frac = size(overlap,1)/datatomatch(time+1).stats(closest_cell).Area;
                
                if overlap_frac>=minpxloverlap  
                    %disp(overlap_frac)
                    tracks_t0(q).coord(time+1,1:2) = cat(1,datatomatch(time+1).stats(closest_cell).Centroid);
                    tracks_t0(q).coord(time+1,3)=overlap_frac;
                    tracks_t0(q).coord(time+1,4)=closest_cell_dist;
                    tracks_t0(q).indx=closest_cell;
                    tracks_t0(q).indx2=jj;
                end 
            end
            if tmp1.distance>maxdist_tomove                                
                continue           
            end           
            q = q+1;       
        end
end% time loop
end