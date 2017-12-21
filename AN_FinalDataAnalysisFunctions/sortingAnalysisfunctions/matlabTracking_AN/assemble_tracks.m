function [coordintime,coordintime_subtracks,coordintime_merged,coordintime_trackwithbreaks]=assemble_tracks(plottracks,tr_1,tr_end,delta_t,tracks_all,datatomatch,allowedgap)

coordintime = struct;
coordintime_merged = struct;
coordintime_subtracks = struct;
coordintime_trackwithbreaks = struct;
if isempty(tr_end)
    tr_end = size(tracks_all,2);
end
for totrack = tr_1:tr_end%
if ~isempty(tracks_all(totrack).coord)    
coordintime(totrack).dat =tracks_all(totrack).coord;
[tmp3,~]=find(coordintime(totrack).dat(:,5) == 0); % see if there are breaks in the track (zero coordinate)
% merge tracks if only small gap 
if  (size(tmp3,1)<=allowedgap) && (size(tmp3,1)>0)
   toreplace =  tracks_all(totrack).coord(tmp3(1)-1,1:4);
   coordintime_merged(totrack).dat = tracks_all(totrack).coord;
   coordintime_merged(totrack).dat(tmp3,1:4) = toreplace.*ones(size(tmp3,1),size(tracks_all(totrack).coord,2)-1);
   coordintime_merged(totrack).dat(tmp3,5) = tmp3;
end
% TODO: plot full tracks even if the cell was lost, set the lost time
% points to NaNs and plot the tracks on the image, to see what happened at
% the point when cell was lost
xintime = round(coordintime(totrack).dat(:,1));
xintime(xintime==0) = NaN;
yintime = round(coordintime(totrack).dat(:,2));
yintime(yintime==0) = NaN;
overlap = coordintime(totrack).dat(:,3);
timepoints= coordintime(totrack).dat(:,5);
timepoints(timepoints==0) = NaN;
separation_inT = coordintime(totrack).dat(:,4);
coordintime_trackwithbreaks(totrack).dat = cat(2,xintime,yintime,timepoints,overlap,separation_inT);
if plottracks == 1
xintime = round(coordintime(totrack).dat(:,1));
yintime = round(coordintime(totrack).dat(:,2));
overlap = coordintime(totrack).dat(:,3);
timepoints= coordintime(totrack).dat(:,5);
timepoints(timepoints==0) = NaN;
separation_inT = coordintime(totrack).dat(:,4);
%disp(['first broken track' num2str(totrack)])
%tmp3(1) = is the firt time point where the cell was lost
% size(tmp3,1) % how many zero coordinates (time points where the cell was not found) in the middle of the track there are
 startpt =1;  
  endpt =size(xintime,1);% needs to be the last tracked time point
figure(totrack), imshowpair(datatomatch(endpt).img,datatomatch(startpt).img,'ColorChannels','red-cyan'), hold on;
%figure(1), imshow(datatomatch(endpt).img,[]), hold on;
plot(nonzeros(xintime),nonzeros(yintime),'-bp','MarkerSize',10,'LineWidth',2);hold on
%text(xintime(2:end-1)+2,yintime(2:end-1)+2,num2str(overlap(2:end-1)),'Color','r');hold on
text(xintime(1)+2,yintime(1)+2,num2str(overlap(1)),'Color','m');hold on
text(xintime(end)+2,yintime(end)+2,num2str(overlap(end)),'Color','g');hold on
plot(xintime(end),yintime(end),'p','MarkerSize',15,'MarkerFaceColor','g');hold on
plot(xintime(1),yintime(1),'p','MarkerSize',15,'MarkerFaceColor','m');hold on

%text(xintime(2:end-1),yintime(2:end-1)+3,num2str(separation_inT(2:end-1)),'Color','b');hold on
text(xintime(end),yintime(end)+3,num2str(separation_inT(end)),'Color','g');hold on
text(xintime(1),yintime(1)+3,num2str(separation_inT(1)),'Color','m');hold on
if size(tmp3,1)==0 || size(tmp3,1)<=allowedgap
figure(totrack),title(['Track N# ' num2str(totrack) ';last tp= ' num2str(endpt*delta_t/60) 'hrs; show tp0(cyan) and tp ' num2str(endpt*delta_t/60) 'hrs(red);Continuous track']);
% if the track was lost for <=2 time points, asume that it's the same cell
% that was picked up and can merge the track
end
if size(tmp3,1)>allowedgap    
figure(totrack),title(['Track N# ' num2str(totrack) '; show tp0(cyan) and tp ' num2str(endpt*delta_t/60) 'hrs(red);Non-Continuous track, lost for ' num2str(size(tmp3,1)) ' tpts']);
% if the cell was lost for more than 2 tpts, assign the track to new cell,
% carry over the time point that this happened at
end
end
% the piece below parces the individual track and finds the breaks in the track (lost cell or new cell), then
% the track is divided into subtracks that are later assigned a new trackID
% within a coordintime_subtracks structure
trackBreakPts = abs(coordintime(totrack).dat(1:end-1,5)-coordintime(totrack).dat(2:end,5));
newTr_timecoord = find(trackBreakPts>1);
newTr_timecoord2 = cat(1,coordintime(totrack).dat(1,5),newTr_timecoord,coordintime(totrack).dat(end,5));
seprate_tracks = size(newTr_timecoord2,1)/2; % how many broken tracks are there (divide by 2 since each track has start and stop)
seprate_tracks_dat = zeros(seprate_tracks,2);
seprate_tracks_dat2= zeros(seprate_tracks,2);
q = 1;
for jj=1:2:size(newTr_timecoord2,1)    
seprate_tracks_dat(q,1:2) = newTr_timecoord2(jj:jj+1);
q = q+1;
end
tmpvect = ones(size(seprate_tracks_dat,1),1);
tmpvect(1) = 0;
adjust_vect= seprate_tracks_dat(:,1)+tmpvect;
seprate_tracks_dat2 = cat(2,adjust_vect,seprate_tracks_dat(:,2));

 % the seprate_tracks_dat2 contains the time points for the 'subtracks'
 % (row,1:2) = subtrack with time coordinates (row,1) till (row,2)
 % within the track; now need to assign new trackID to them, since they
 % probably belong to different cell, as the break in time was more than 2
 % time points 
 coordintime(totrack).dat = tracks_all(totrack).coord(seprate_tracks_dat2(1,1):seprate_tracks_dat2(1,2),:);
 coordintime(totrack).subtracks = seprate_tracks_dat2;
 % the first subtrack retains the same ID (totrack)

% all the next subtracks get added to the new structure that will be
% mergedlater with the original, to contain only the continuous tracks

if totrack == tr_1 % TODO: make this first non-empty track
qq = 0;
end
%disp(seprate_tracks_dat2)
for h=1:(seprate_tracks-1)
coordintime_subtracks(h+qq).dat = tracks_all(totrack).coord(seprate_tracks_dat2(1+h,1):seprate_tracks_dat2(1+h,2),:);
end
qq = (seprate_tracks-1)*totrack;

end
end


end


