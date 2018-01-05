%% extract tracks from Ilastik file
% here fully use Ilastik Automatic tracking 
pos = 1;%1
chan = 0;% 0 - cfp cells; 1- nuc marker of other cell type
paramfile = 'C:\Users\Nastya\Desktop\FromGithub\CellTracker\paramFiles\setUserParamTrackSortingAN_20X.m';
delta_t = 15;%15
il_tracks = 'SortingGFPS4cellspluri70to30_MIP_80tpts_testDynamics_MIP_f0000_w0000_Tracking-Result.h5';
[coordintime] = process_ilastik_trackAN(il_tracks);
%TODO: save the info on tracks into a file
%% load the raw images data for selected channel
imagedir  ='C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff';
ff1 = readAndorDirectory(imagedir); 
nucmoviefile = getAndorFileName(ff1,ff1.p(pos),[],[],chan);%getAndorFileName(files,pos,time,z,w)
% nreader = bfGetReader(nucmoviefile);
% nt = nreader.getSizeT;
r3 = bfopen(nucmoviefile);

%% get the movie of the track for the selected track number 'totrack'
celltype = 'CFP';%CFP
matlabtracking = 0;
totrack =128; 
%good track IDs: %11,13,17,19,20,22,23,24,25,31*,33,34,36*,38,43(div.,then track CM), 
%good track IDs: 44,50,53,56,57,58,59,61,66*,68,69,71,72,75,77*,79*,83,86*,88,89,100,101*,104,105,107*,110
%goodtracks = [11,13,17,19,20,22,23,24,25,33,34,38,44,50,53,56,57,58,59,61,68,69,71,72,75,83,88,89,100,104,105,110,113];
%nt = size(r{1},1);
nt = 80; % segmented only 80 tpts
trackcelltype_movie = ViewTrack_getMovie(coordintime,celltype,matlabtracking,totrack,r3);
%% run the movie
close all
h = figure(1);%h.Colormap = jet; %
movie(h,trackcelltype_movie,1,1);%,[0 0 560 420]
% save the movie
% pos1 = ff1.p(pos);
% pos_video = VideoWriter(['C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\Ilastik_AutoTracked_movies\TrackSortingCells_Movie_pos_' num2str(pos1) ' Track# ' num2str(totrack) ' CellType_' celltype '.avi']);%C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\Sorting_Movie_with_CellTrack
% pos_video.FrameRate = 2;
% open(pos_video);
% writeVideo(pos_video,trackcelltype_movie);
% close(pos_video);
%%
direc_pluri ='C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff';
ifile_pluri = 'C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff\SortingGFPS4cellspluri70to30_MIP_f0000_w0001_Simple Segmentation.h5';
pos = 1;%1
chan_pluri = 1;% 0 - cfp cells; 1- nuc marker of other cell type
paramfile = 'C:\Users\Nastya\Desktop\FromGithub\CellTracker\paramFiles\setUserParamTrackSortingAN_20X.m';
direc_diff  ='C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff';
chan_diff = 0;
ifile_diff = 'C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff\SortingGFPS4cellspluri70to30_MIP_f0000_w0000_Simple Segmentation.h5';
[pluristats,diffstats,img_pluri,img_diff]=get_celltypes_statsimages(direc_pluri,ifile_pluri,direc_diff,ifile_diff,paramfile,pos,chan_diff,chan_pluri);
%% 
close all
goodtracks = [11,13,17,19,20,22,23,24,25,33,34,38,44,50,53,56,57,58,59,61,68,69,71,72,75,83,88,89,100,104,105,110,113,121,125,128];
%close all
local_neighbors = struct;
msd_all = struct;
frac_init = zeros(size(goodtracks,2),1);
DiffC = zeros(size(goodtracks,2),1);
counter = 0;
toplot = 0;
toplot2 = 0;
x1 = 8;
for ii=1:size(goodtracks,2)
    counter = counter+1;
    trackID =goodtracks(ii); 
matlabtracking = 0;% was it ilastik-generated track or matlab-generated
delta_t = 15;
paramfile = 'C:\Users\Nastya\Desktop\FromGithub\CellTracker\paramFiles\setUserParamTrackSortingAN_20X.m';
[samecell_neighbors,othercell_neighbors,curr_cell_speed,curr_cell_rad]=...
    getDynamicLocalNeighborsAN(trackID,paramfile,coordintime,matlabtracking,delta_t,pluristats,diffstats,img_pluri,img_diff,toplot);
% get the msd for the track colorcoded by the local neighborhood
%close all
local_neighbors(ii).dat = samecell_neighbors;
[msd,slope_estimate,D,diff_coeff,mean_disp,total_disp,mean_speed,validTracks,MD,mspeed,TP,fit_out] = ...
getCellmovement_params_IlastikTrack(coordintime,delta_t,trackID,x1,paramfile,samecell_neighbors,toplot2);
msd_all(ii).dat = msd(goodtracks(ii)).dat;
if toplot2 ==1
figure(1),hold on
h = figure(1);
h.Colormap = jet;
caxis([0 1]);
ylim([0 7000])
end
frac_init(ii,1) = mean(samecell_neighbors(1:x1));%1:x1
DiffC(ii,1) = diff_coeff;
end
figure(10), plot(frac_init,round(DiffC),'p','Markersize',13,'MarkerEdgeColor','k','MarkerFaceColor','m');box on;  hold on
xlabel(['Mean fraction of same cell type neighbors during ' num2str(x1*delta_t/60) 'hrs']);
xlim([0 1.05])
ylabel(['Estimated D [um^2/hr] from initial ~ ' num2str(x1*delta_t/60) '-hrs long motion']);
[r,~]=find(isnan(frac_init));
frac_init(r) = [];
DiffC(r) = [];
cc = corrcoef(frac_init,DiffC);
cc = cc(1,2);
title(['Total ' num2str(counter) ' uninterrupted tracks;']);

%% separate the msd data based on the starting fraction of sametype cells in
% the local neighborhood 
% TODO: separate these based on the start positionof the cell within the
% colony
close all
thresh_frac1 = 0.5;
thresh_frac2 = 0.5;
clear tmp_var
for jj=1:size(msd_all,2)
tmp_var = mean(local_neighbors(jj).dat(1:x1));
if tmp_var<=thresh_frac1 
figure(3),plot(msd_all(jj).dat(:,2).*delta_t/60,msd_all(jj).dat(:,1),'pm');box on; hold on
%title(['Initial fraction of neighbors of the same cell type is less than ' num2str(thresh_frac) ])
xlabel('Time,hrs')
ylabel('MSD,um^2/hr')
legend(['Fraction of same cell neighbors during initial' num2str(x1*delta_t/60) 'hrs is <= than ' num2str(thresh_frac1) ] );
end
if tmp_var>thresh_frac2 
figure(4),plot(msd_all(jj).dat(:,2).*delta_t/60,msd_all(jj).dat(:,1),'pb');box on; hold on
xlabel('Time,hrs')
ylabel('MSD,um^2/hr')
legend(['Fraction of same cell neighbors during initial' num2str(x1*delta_t/60) 'hrs is > than ' num2str(thresh_frac2) ] );
end

end


