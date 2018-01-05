
function [coordintime] = process_ilastik_trackAN(il_tracks)
% process the  output of the ilastik tracking file
% cannot get the CSV table, only could get the .h5 , each image has the
% cell already labeled with unique trackID
trackout_h5 = h5read(il_tracks,'/exported_data');
h5disp('SortingGFPS4cellspluri70to30_MIP_80tpts_testDynamics_MIP_f0000_w0000_Tracking-Result.h5','/exported_data');
track_mask = squeeze(trackout_h5); % labeled masks, each object has the same pxl value in time
%track_mask2 = uint16(track_mask);%
%at each time point the number of objects will be different, but the same
%objects will have the same  pixel values (if tracked from the previous
%time frame)
coordintime = [];
img_stats = [];
ncells = size(img_stats,1);
nT = size(track_mask,3);
% get the track of the single object in time (until it is tracked)
N = 1;%size(img_stats(tp).dat(objID).PixelIdxList,1);
for ii=1:nT    
    % loop over image objects
    img_stats(ii).dat = regionprops(track_mask(:,:,ii),'Centroid','PixelIdxList');
    for objID = 1:size(img_stats(ii).dat,1)
        %disp(size(img_stats(ii).dat,1))
        if ~ isempty(img_stats(ii).dat(objID).PixelIdxList)
        % at each time point find the centroid of the object, whos pixel
        % values are == objID
        coordintime(objID).dat(ii,1:2) = round(img_stats(ii).dat(objID).Centroid);
        coordintime(objID).dat(ii,3) = ii; % time point
    end
    end
end
coordintime(objID).dat
% TODO: how to extract divisions and merged objects from the h5 file
end

