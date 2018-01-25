%% try the uCOl segm and tracking routine for the sorting data (from runlivecell_newsegm.mat

toshift = 0;
matchdist = 150;% 150
shiftframe = [];

direc1 ='/Volumes/TOSHIBAexte/2017-06-29-livesorting_SDConfocalbetaCatcellspluri/2017-07-05-liveSortingMaxProjections';
direc2 = [];

ff1 = readAndorDirectory(direc1);% nuc
%ff2 = readAndorDirectory(direc2);% cyto
discardarea =200; % 
mag = 20;
chan = [0,1,2];% sorting beta cat: rfp gfp cfp
cellIntensity = 1400;% for pluri   280 % does not matter, since the nuc masks are from ilastik
cellIntensity1 = 100; % % jan8set timegroup2 100 %380 for feb set bright, 200-300 for dim positions % for cyto pluri 180 % 260-300 for tiling 1; 220 for nov12 set % 300 for BMP4 only set % for tiling2 set:350
for ii = 6%30:length(ff1.p) 
    disp(['Movie ' int2str(ff1.p(ii))]);
    nucmoviefile = getAndorFileName(ff1,ff1.p(ii),2,0,2);   % nuc channel ( last function argument)
    %fmoviefile = getAndorFileName(ff2,ff2.p(ii),2,0,1);     % cyto channel
    [nmask,nuc_p] = segmentnuc(nucmoviefile,mag,cellIntensity);
    stmp = strsplit(nucmoviefile,direc1);
    ifile = ['/Users/warmflashlab/Desktop/JANYARY_8_DATA_ilasik/2016-11-03-jan8data_projections_tg2/nuc_projections_tg2/' stmp{end}(2:(end-4)) '_{simplesegm}.h5'];%stmp{end-1}(2:end)
    nmask = readIlastikFile(ifile);
    nmask = cleanIlastikMasks(nmask,discardarea);% area filter last argument
    [newmasks, colonies] = statsArrayToSplitMasks(nmask,nuc_p,fimg_p,cmask,toshift,matchdist,shiftframe);
    outfile = [int2str(ff1.p(ii)) '_jan8tg2.mat'];
    saveLiveCellData(outfile,newmasks,cmask,colonies);
end

%% import ilastic tracking output into mat variable
close all
clear all
csvfile = '/Volumes/TOSHIBAexte/2017-06-29-livesorting_SDConfocalbetaCatcellspluri/2017-07-05-liveSortingMaxProjections/SortingBetaCatpluri_MIP_f0005_w0002-exported_data_table.csv';
imported_dat = uiimport(csvfile);

%imported_dat.data(:,2);
% lineage_id = imported_dat.data(:,4);
% track_id1= imported_dat.data(:,5);
% RegionCenter_0= imported_dat.data(:,9);
% RegionCenter_1= imported_dat.data(:,10);
% save('importedtracks.mat');% save all created variabes
%% look at traces on images
%load('importedtracks.mat');
flag = 1;
trN = 21;
pos = 6;
plot_ilastiktrack(trN,imported_dat,pos,flag);


%% group the cells at initial or other time point into colonies and find track Numbers of cells specific to each separate colony

object_id = imported_dat.data(:,1);
timestep = imported_dat.data(:,2);
lineage_id = imported_dat.data(:,4);
track_id1= imported_dat.data(:,5);
RegionCenter_0= imported_dat.data(:,9);
RegionCenter_1= imported_dat.data(:,10);
   
tpt = 2;
% need to get the x y coordinates of all cells at time point 0
% then use these to group into colonies
txy=cat(2,timestep,RegionCenter_0,RegionCenter_1);
[initcells,~]= find(timestep == tpt);
mainvar=zeros(size(initcells,1),3);
mainvar(:,1) = RegionCenter_0(initcells,1);
mainvar(:,2) = RegionCenter_1(initcells,1);
mainvar(:,3) = track_id1(initcells,1);% track ID of the cells within colony

% group these into colonies first then consider each colony separately?
paramfile = '/Users/warmflashlab/CellTracker/paramFiles/setUserParamAN20X_var.m' ;
%userParam.colonygrouping = 100 (pixels);% set this parameter within the paramfile,
%depending on the colony size that is being connsidered 

run(paramfile)
[groupids]= NewColoniesAW(mainvar);
% plot on top of image time point
direc1 ='/Volumes/TOSHIBAexte/2017-06-29-livesorting_SDConfocalbetaCatcellspluri/2017-07-05-liveSortingMaxProjections';
ff1 = readAndorDirectory(direc1);% nuc
j = pos;
nucmoviefile = getAndorFileName(ff1,ff1.p(j),2,0,2);  
nreader = bfGetReader(nucmoviefile);
nt = nreader.getSizeT;
ii = tpt+1;   
    iplane = nreader.getIndex(0,0,ii-1)+1;
    nuc = bfGetPlane(nreader,iplane);  

figure(3), imshow(imadjust(nuc,stretchlim(nuc)),[]);hold on
plot(mainvar(:,1),mainvar(:,2),'rp','Markersize',12);hold on
text(mainvar(:,1)+20,mainvar(:,2)+20,num2str(groupids),'Color','c','FontSize',16)

sortingcol = cat(2,mainvar,groupids); % column1 = x coord of cell, col2 = y coord of cell, col3 = track ID of cell; col4 = colony identity (same number means same colony)
numcols = size(unique(groupids),1);

%% find the track ids of the cells within the same colony 
close all
colN = 3; % want to look at tracks of colony colN
flag = 0;
[r,~] = find(groupids == colN);
trNinonecol= sortingcol(r,3);
colormap = prism;
data = struct;
for jj=1:size(trNinonecol,1);  
if trNinonecol(jj) >0
[x,y,time,r3,nuc,nuc2]=plot_ilastiktrack(trNinonecol(jj),imported_dat,pos,flag); % r3 is the region center coordinate identified with the same trN in time
data(jj).x = x;
data(jj).y = y;
data(jj).t = time;
data(jj).r3 = r3;
data(jj).trN = trNinonecol(jj);
data(jj).imgstart = nuc;
data(jj).imgend = nuc2;

else
    disp('this track is empty')
end
end
% the images shown is of the last track start and end time point
for jj=1:size(data,2)
    if ~isempty(data(jj).x)
    figure(jj),  imshowpair(imadjust(data(jj).imgstart,stretchlim(data(jj).imgstart)),imadjust(data(jj).imgend,stretchlim(data(jj).imgend)),'ColorChannels','red-cyan');hold on
   
    figure(jj),plot(data(jj).x,data(jj).y,'bp-','Markersize',5,'LineWidth',3);hold on
    figure(jj),plot(data(jj).x(1),data(jj).y(1),'mp-','Markersize',20,'MarkerFaceColor','r');hold on
    text(data(jj).x(1),data(jj).y(1),['Start,' num2str(data(jj).t(1))],'FontSize',20,'Color',colormap(jj,:));hold on
    figure(jj),plot(data(jj).x(end),data(jj).y(end),'mp-','Markersize',20,'MarkerFaceColor','y');hold on
    text(data(jj).x(end),data(jj).y(end),['End,' num2str(data(jj).t(end))],'FontSize',20,'Color',colormap(jj,:));hold on

figure(size(data,2)+1),plot(data(jj).t,RegionCenter_0(data(jj).r3),'Color',colormap(jj,:),'LineWidth',3);ylim([0 max(RegionCenter_0(data(jj).r3))+200]);box on; hold on
h=figure(size(data,2)+1);
h.CurrentAxes.LineWidth = 3;
h.CurrentAxes.FontSize = 22;
xlabel('time, frames');
ylabel('RegionCenter0 coordinate (ilasik)')

    end
end


%% determine velocity 
%  need  to put together the tracks, that are split, but still
% correspond to the same cell

% use the Rgion Center to calculate the velocity at each
    % time point or average velocity over the current time interval  
    shortesttrack = 10;
    dt0 = 15; % in minutes
    %dx must be in pixels   
     pxtomicron = 0.325; % SD confocal 20X
     %speed = {pixels*(micron/pixels))}/((t2-t1)*dt/60)) 
     % speed = pixels/hour
     colormap2 = jet;
     close all
     txy = [];
for colonytrack =1:size(data,2);% need to loop over tracks of a  given colony
v = [];
dispacement = [];
if (~isempty(data(colonytrack).t)) && (size(data(colonytrack).t,1)>shortesttrack)
    txy = cat(2,data(colonytrack).t,data(colonytrack).x,data(colonytrack).y,ones(size(data(colonytrack).y,1),1)*data(colonytrack).trN);
    
    for jj=1:(size(data(colonytrack).t,1)-1)% loop over time points in the track
        tp1 =jj;
        tp2 = jj+1;
        d0 = power((power(txy(tp2,1)-txy(tp1,1),2)+power(txy(tp2,2)-txy(tp1,2),2)),0.5);%
        % distance traveled by cell celnter in time from tp1 to tp2
        dt = ((tp2-tp1))*(dt0/60);% time interval in hours
        TP(jj,1:2) = [tp1 tp2];        
        dx = d0* pxtomicron;% in microns
        v(jj,1:2) = [data(colonytrack).t(jj);  dx/dt];% in micons/hour
        dispacement(jj,1:2) = [data(colonytrack).t(jj);  dx];% in micons
    end
    xx = randi(60);
    hold on;figure(colonytrack),plot((v(:,1)*dt0/60),v(:,2),'p','MarkerFaceCOlor',colormap2(xx,:),'Markersize',18); box on
    
    h  = figure(colonytrack);
    h.CurrentAxes.LineWidth = 3;
    h.CurrentAxes.FontSize = 18;
    h.CurrentAxes.XTick = [1:5:nt];%round((nt*dt0/60))
    h.CurrentAxes.XLim = [0 round((nt*dt0/60))];
    h.CurrentAxes.YLim = [-5 15];
    xlabel('time, hours');
    ylabel('Cell speed, um/hour')%/hour
    title(['ColN = '  num2str(colN) ';Tracks IDs found at t = ' num2str(tpt*dt0/60) ' hours; trN' num2str(txy(colonytrack,4)) ]);
    figure(size(data,2)+1), plot(v(:,1)*dt0/60,dispacement(:,2),'p','MarkerFaceCOlor',colormap2(xx,:),'Markersize',18);hold on; box on
    ylabel('Displ. wrt track start, microns');
    xlabel('time, hours');
    h = figure(size(data,2)+1);
    h.CurrentAxes.FontSize = 18;
    h.CurrentAxes.LineWidth = 3;
    title(['Cells within colony N '  num2str(colN) ]);
    
else
    disp('this track is empty')
end
end
 % still need to determine the direction of movement of each cell 
%%
% determine the colony center
% since there are multiple colonies in the image, need to 
% 1. get the colony ID at tp=0;
% 2. then get the x,y coordnates of the cells within that colony (get them
% from the tracking data RegionCenter coord at the beginning of the track
% for that colony;
% 3. To find colony center, find the point that is most equidistant to all the points in the
% colony









% 





