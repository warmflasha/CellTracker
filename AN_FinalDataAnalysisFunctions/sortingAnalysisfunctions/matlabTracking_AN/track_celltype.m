% in progress function to track the sorting cells
% Algorythm/procedure:
% 1.  Load the image sequence/movie for the cells of type 1
% 2.  Segment all of the time points (subtrackt background, very basic
% segmenttion, since need here only the velocities, not fluorescence
% quantification)
% 3.  Get the centroid of each object and assign a number to it
%   Note: if the image contains multiple colonies, use the cell centroid
% coordinates to dynamically assign colony ID to each cell (I already wrote the function to do this,
% it is called assigncellstosamecolonyintime.m 
% 3a. each cell needs to be a group of pixels equal to a number;
%  4. then take the next time point and assign number of track to the
%  object, if its centroid intersects with the dilated centroid of the
%  previous time point (same idea as in assigncellstosamecolonyintime.m,
%  when assigning cells to colony intime)
%  4.a or can use the ipdm, need to see which is easier
%  5. Assign the same track to the current centroid, if it intersects
%  with the dilated centroid of the previous time point. 
%  6. Do for each time point
%  7. Handling cases:
% - if a new cell is found, that doesn't match any of the tracks, assign a
% new track number to it 
% - if a cell disappears, do nothing
% - if a cell divides, do nothing (for now)
%  8. Store the centroid coordinate and it's trackID in time in a struct,
%  or somth else

%paramfile = '/Users/warmflashlab/CellTracker/paramFiles/setUserParamAN20X_var.m' ;
direc1 ='C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff';
pos = 1;%
chan = 0;% 0 - cfp cells; 1- nuc marker of other cell type
init = 1;
arealow = 80;
areahi = 500;
toshow = 1;
[ilbl,stats,nt]=getinitmasktotrack(direc1,pos,chan,init,arealow,areahi,toshow);
% ilbl is the mask at time point  = init
% the actual cell object labeling based on pixel list is useless for
% tracking,can use it later ????

%% get masks from ilastik segmentation
direc1 ='C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff';
pos = 1;%
chan = 0;% 0 - cfp cells; 1- nuc marker of other cell type
arealow = 130;%130
ff1 = readAndorDirectory(direc1);
nucmoviefile = getAndorFileName(ff1,ff1.p(pos),2,0,chan);
%stmp = strsplit(nucmoviefile,direc1);
%ifile = ['/Users/warmflashlab/Desktop/JANYARY_8_DATA_ilasik/2016-11-03-jan8data_projections_tg2/nuc_projections_tg2/' stmp{end}(2:(end-4)) '_{simplesegm}.h5'];%stmp{end-1}(2:end)
ifile = ['C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff\SortingGFPS4cellspluri70to30_MIP_f0000_w0000_Simple Segmentation.h5'];%stmp{end-1}(2:end)
nmask = readIlastikFile(ifile);
nmask = cleanIlastikMasks(nmask,arealow);% area filter last argument
close all,imshowpair(nmask(:,:,2),nmask(:,:,3),'ColorChannels','red-cyan');
datatomatch = struct;
statstmp = [];
for k=1:size(nmask,3) % only imported 80 tpts for this dataset(since sorting is done at that time point)
tmpmask = imerode(nmask(:,:,k),strel('disk',1));% erode such that avoid merged objects 
statstmp = regionprops(tmpmask,'Area','Centroid','PixelIdxList');
datatomatch(k).stats = statstmp;
datatomatch(k).img = tmpmask;%nmask(:,:,k);
end
%save('Smad4withCFPsort_testTracking','datatomatch','arealow','chan','pos');
%%
load('C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\Smad4withCFPsort_testTracking.mat');
%% test tracking
minpxloverlap =40; % 40 TODO: put these params into a parameter file for tracking
maxdist_tomove=25; % 20 pixels is ~ a cell diameter at 20X
delta_t = 15; % in minutes
% tpt = which time point to strart the track from (returns matched cells at
% tpt and tpt-1
tpt = 2;
clear tracks_t0
tracks_t0 = init_tracks(minpxloverlap,maxdist_tomove,datatomatch,tpt);
% now the cell are assigned track number, need to keep this number with the
% cell
% loop over initially found/started tracks cells
tracks_all = struct;
for ii=50:55%:size(tracks_t0,2) % 50:55  100:105
    tracks_t0(ii).coord;
    t = 60;% how many time points to track till (note that tpt-1 and tpt is where the tracks start)
    if size(tracks_t0(ii).coord,1) >1 % only look further at cells that were identified initially as having a cell at the next time point
    tracks_all(ii).coord(1:2,:)= tracks_t0(ii).coord;    
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
                 
            % TODO: better to estimate the fraction of the current total
            % cell areas that overlap, not the absolute area
            if size(overlap,1)>=minpxloverlap
                % TODO: check that the overlap wan not between several objects(?)      
                disp('match in distance and overlap');
                tracks_all(ii).coord(time+1,1:2) = cat(1,datatomatch(time+1).stats(closest_cell).Centroid);
                tracks_all(ii).coord(time+1,3)=size(overlap,1);
                tracks_all(ii).coord(time+1,4)=closest_cell_dist;
                tmp0 = tracks_all(ii).coord(time+1,1:2);  
                tofindcellindx = cat(1,datatomatch(time+1).stats.Centroid);% 
                [r,~] = find(tofindcellindx == tmp0);                
            end
            if size(overlap,1)<minpxloverlap
                disp('match in distance ,no match in overlap');
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
% TODO: regroup the tracks after they are done (if there's no overlap in
% the track for more than 2 time pts, and then the track starts again,
% likely a different cell taht was picked up, need to assign this to a new
% track

% TODO: then save the matfile with all the tracks and the info on
% parameters used for tracking
%%
close all
coordintime = struct;
for totrack =54%use cells 50,52,83 to write the code to analyze the cell trajectory(at the arealow = 130)
startpt =1;
coordintime(totrack).dat =tracks_all(totrack).coord;
xintime = round(coordintime(totrack).dat(:,1));
yintime = round(coordintime(totrack).dat(:,2));
endpt =size(xintime,1);% t  size(tracks_all(totrack).coord,1);% needs to be the last tracked time point
overlap = coordintime(totrack).dat(:,3);
separation_inT = coordintime(totrack).dat(:,4);

[tmp3,~]=find(coordintime(totrack).dat(:,1) == 0); % see if there are breaks in the track (zero coordinate)
% size(tmp3,1) % how many zero coordinates (time points where the cell was not found) in the middle of the track there are
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
if size(tmp3,1)==0 || size(tmp3,1)<2
figure(totrack),title(['Track N# ' num2str(totrack) ';last tp= ' num2str(endpt*delta_t/60) 'hrs; show tp0(cyan) and tp ' num2str(endpt*delta_t/60) 'hrs(red);Continuous track']);
end
if size(tmp3,1)>2
figure(totrack),title(['Track N# ' num2str(totrack) '; show tp0(cyan) and tp ' num2str(endpt*delta_t/60) 'hrs(red);Non-Continuous track, lost for >2 tpts']);
end
end
%
%TODO:here need to merge the tracks that have small time gaps in them or
%assign new track numbers to the tracks that obviously belong to the
%different cell that was picked up at later time point
% then can do the MSD analysis for all the tracks
%% get cell displacement using tracking output above (ilastik segm + AN tracking algorythm (ipdm + cellarea overlap at each tp))
 close all
 pxtomicron = 0.3215;
 txy = [];
 delta_t = 15;%*60 seconds
 coordintime(totrack).dat; 
 shortesttrack = 20;
 colormap2 = jet;
 TP = [];
 %delta_t
 lagtimes = 8;
 msd = zeros(lagtimes,2);
 clear displacement2
for colonytrack = totrack % need to loop over tracks of a  given colony
v = [];
dispacement = [];
if (~isempty(coordintime(totrack).dat)) && (size(coordintime(totrack).dat,1)>shortesttrack)
    txy = cat(2,(1:size(coordintime(totrack).dat,1))',coordintime(totrack).dat(:,1:2).*pxtomicron);
    for ii=1:lagtimes
       dispacement2 = []; 
    for jj=1:ii:(size(coordintime(totrack).dat,1)-ii)% loop over time points in the track
        tp1 =jj;
        tp2 = jj+ii;
       % distance traveled by cell celnter in time from tp1 to tp2
       % TODO: select the positive and negative directions, then calculate
       % the d0
       d0 = power((power(txy(tp2,1)-txy(tp1,1),2)+power(txy(tp2,2)-txy(tp1,2),2)),0.5);%
       % squared dispalcement traveled by cell celnter in time from tp1 to tp2  
       d2 = ((power(txy(tp2,1)-txy(tp1,1),2)+power(txy(tp2,2)-txy(tp1,2),2)));%
       dt = ((tp2-tp1))*(delta_t/60);% time interval in hours
        TP(jj,1:3) = [tp1 tp2 dt];        
        v(jj,1:2) = [txy(jj,1);  d0/dt];% in micons/hour
        dispacement(jj,1:2) = [jj;  d0];% in micons
        dispacement2(jj,1:2) = [jj;  d2];% in micons
    end
    % disp(size(nonzeros(dispacement2(:,2))));
    msd(ii,1) = sum(nonzeros(dispacement2(:,2)))/((size(coordintime(totrack).dat,1)*delta_t)/60); %[microns^2/hour] lag time = delta_t;
    % to check: average over all observation time, regardless of lag time?
    msd(ii,2) = ii; % how many delta_t intervals taken as the lag time
    %disp(((size(nonzeros(dispacement2(:,2)),1)*delta_t)/60))
    disp((size(coordintime(totrack).dat,1)*delta_t)/60);
    end
    xx = randi(60);
    hold on;figure(1),plot(msd(:,2),msd(:,1),'-p','MarkerFaceCOlor',colormap2(xx,:),'Markersize',14); box on
    h  = figure(1);
    h.CurrentAxes.LineWidth = 2;
    h.CurrentAxes.FontSize = 10;
    xlabel('Lag time in multiples of imaging step');
    ylabel('Mean Square Displacement, um^2/hour')%/hour
    title(['MSD is time averaged over total track length ' num2str((size(coordintime(totrack).dat,1)*delta_t)/60) 'hrs, at each lag time']);
    xlim([0 lagtimes]);
      ylim([0 round(max(msd(:,1)))+10]);
    else
    disp('this track is empty')
end
end
 % still need to determine the direction of movement of each cell
