%% extract tracks from Ilastik file
% here fully use Ilastik Automatic tracking 
pos = 1;%1
chan = 1;% ff.w(chan): 0 - cfp cells; 1- nuc marker of other cell type
paramfile = 'C:\Users\Nastya\Desktop\FromGithub\CellTracker\paramFiles\setUserParamTrackSortingAN_20X.m';
delta_t = 15;%15
ff_tmp = readAndorDirectory('.');
if ff_tmp.p(pos)<10
il_tracks = ['SortingGFPS4cellspluri70to30_MIP_80tpts_testDynamics_MIP_f000' num2str(ff_tmp.p(pos)) '_w000' num2str(ff_tmp.w(chan)) '_Tracking-Result.h5'];
end
if ff_tmp.p(pos)>=10
il_tracks = ['SortingGFPS4cellspluri70to30_MIP_80tpts_testDynamics_MIP_f00' num2str(ff_tmp.p(pos)) '_w000' num2str(ff_tmp.w(chan)) '_Tracking-Result.h5'];
end
[coordintime] = process_ilastik_trackAN(il_tracks);
%TODO: save the info on tracks into a file
%% load the raw images data for selected channel
pos = 1;
chan = 2;
imagedir  ='C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\2017-07-14-Smad4sorting_maxProjections';
ff1 = readAndorDirectory(imagedir); 
nucmoviefile = getAndorFileName(ff1,ff1.p(pos),[],[],ff1.w(chan));%getAndorFileName(files,pos,time,z,w)
% nreader = bfGetReader(nucmoviefile);
% nt = nreader.getSizeT;
r3 = bfopen(nucmoviefile);
%%
ilastikprob = 1;
global setUserParam 
direc_untracked ='C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff';
%direc_untracked ='C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\2017-07-14-Smad4sorting_maxProjections';
ifile_untracked = 'C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff\SortingGFPS4cellspluri70to30_MIP_80tpts_testDynamics_MIP_f0000_w0000_Probabilities.h5';%'C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff\SortingGFPS4cellspluri70to30_MIP_f0000_w0001_Simple Segmentation.h5';
%ifile_untracked ='C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\2017-07-14-Smad4sorting_maxProjections\SortingGFPS4cellspluri70to30_MIP_f0014_w0001_Simple Segmentation.h5';
pos = 1;%C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\2017-07-14-Smad4sorting_maxProjections\SortingGFPS4cellspluri70to30_MIP_f0014_w0001_Simple Segmentation.h5'
chan_untracked = 0;% 0 - cfp cells; 1- nuc marker of other cell type
paramfile = 'C:\Users\Nastya\Desktop\FromGithub\CellTracker\paramFiles\setUserParamTrackSortingAN_20X.m';
direc_tracked  ='C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff';%'C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff';
chan_tracked = 1;
ifile_tracked = 'C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff\SortingGFPS4cellspluri70to30_MIP_f0000_w0001_Probabilities.h5';
%ifile_diff =['C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff\SortingGFPS4cellspluri70to30_MIP_80tpts_testDynamics_MIP_f0014_w0000_Simple Segmentation.h5'];
[untrackedstats,trackedstats,img_untracked,img_tracked]=get_celltypes_statsimages(direc_untracked,ifile_untracked,direc_tracked,ifile_tracked,paramfile,pos,chan_tracked,chan_untracked,ilastikprob);
%% find numeric ID of the long tracks
q = 1;
longtracks = [];
for jj=1:size(coordintime,2)
tmp = size(coordintime(jj).dat,1);
if tmp >=40
longtracks(q,1) = jj;
end
q = q+1;
end
goodtracks_tmp = nonzeros(longtracks);
%% make movie of the track for the track number 'totrack' to check that the track corresponds to actual cell and good
celltype = 'pluri';%CFP
matlabtracking = 1;%
%pos14 [9,11,19,21,30,36,40,41,57,59*,60,64,65,67,86,88,93,94,100,102,104,133,144,145,147,148,149]
totrack =196% goodtracks_tmp(8) 
% 182 183 185 188 194 196 199 204 214 220 224 229 230 231 232 240 243 249
%good track IDs pos0chanPluri:13
%,36,40,45,49,52,64,79,84,85,93,96,104,108,110,111*,129,131,143,153,160,171,174,182,183,196
%good track IDs pos0chanCFP:
%[17,19,20,24,33,34,38,44,50,53,56,57,58,61,68,69,72,75,83,88,89,104,105,110,125,128]
nt = 80; % segmented only 80 tpts
trackcelltype_movie = ViewTrack_getMovie(coordintime,celltype,matlabtracking,totrack,r3);
%% run the movie
close all
h = figure(1);%h.Colormap = jet; %
movie(h,trackcelltype_movie,1,4);%,[0 0 560 420]
% save the movie
% pos1 = ff1.p(pos);
% pos_video = VideoWriter(['C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\Ilastik_AutoTracked_movies\TrackSortingCells_Movie_pos_' num2str(pos1) ' Track# ' num2str(totrack) ' CellType_' celltype '.avi']);%C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\Sorting_Movie_with_CellTrack
% pos_video.FrameRate = 2;
% open(pos_video);
% writeVideo(pos_video,trackcelltype_movie);
% close(pos_video);

%%
%untrackedstats,trackedstats,img_untracked,img_tracked
%pos0 chan0(cfp): goodtracks =
%[17,19,20,24,34,38,44,50,53,56,57,58,61,68,69,72,75,83,88,89,104,105,110,125,128];%33
% pos0 chan0(cfp): inside colony start [17,19,20,24,34,38,50,53,58,61,69,72,83,88,89,104,110,125] edge [44,56,57,68,75,105,128]
%pos0 chan1(pluri):8,29,38,44,55,70,76,83,97,98,100,101,121,124,131,133,137,143,149,150
goodtracks = [13,36,40,45,49,52,64,79,84,85,93,96,104,108,110,111,129,131,143,153,160,171,174,182,183,196];%
%goodtracks pos14 chan0(cfp)=[9,10,18,139,37,38,40,41,45,53,55,85,90,92,97,99,101,136,141,145];%start as edge cell: [9,10,18,139] start as inside cell: [37,53,55,85,92,97,141,145]
local_neighbors = struct;
msd_all = struct;
frac_init = zeros(size(goodtracks,2),1);
DiffC = zeros(size(goodtracks,2),1);
counter = 0;
toplot =0;
toplot2 =1;
x1 = 8;
shortesttrack = 30;
matlabtracking = 1;% was it ilastik-generated track or matlab-generated

for ii=1:size(goodtracks,2)
  %  if size(coordintime(ii).dat,1)>shortesttrack
    counter = counter+1;
    trackID =goodtracks(ii);    
        delta_t = 15;
        paramfile = 'C:\Users\Nastya\Desktop\FromGithub\CellTracker\paramFiles\setUserParamTrackSortingAN_20X.m';
        [samecell_neighbors,othercell_neighbors,same_neighbor_abs,other_neighbor_abs,curr_cell_speed,curr_cell_rad]=...
            getDynamicLocalNeighborsAN(trackID,paramfile,coordintime,matlabtracking,delta_t,untrackedstats,trackedstats,img_untracked,img_tracked,toplot);%untrackedstats,trackedstats,img_untracked,img_tracked
        % get the msd for the track colorcoded by the local neighborhood
        %close all
        local_neighbors(ii).dat = othercell_neighbors;%samecell_neighbors
        [msd,slope_estimate,D,diff_coeff,mean_disp,total_disp,mean_speed,validTracks,MD,mspeed,TP,fit_out] = ...
            getCellmovement_params_IlastikTrack(coordintime,delta_t,trackID,x1,paramfile,othercell_neighbors,toplot2);
        msd_all(ii).dat = msd(goodtracks(ii)).dat;
        if toplot2 ==1
            figure(1),hold on
            h = figure(1);
            h.Colormap = jet;
            caxis([0 1]);
            ylim([0 5000])
        end
        frac_init(ii,1) = (mean(othercell_neighbors(1:x1)));%1:x1
        DiffC(ii,1) = diff_coeff;
    %end
end
hold on,figure(10), plot(frac_init,round(DiffC),'p','Markersize',13,'MarkerEdgeColor','k','MarkerFaceColor','m');box on;  hold on
xlabel(['Mean fraction of other cell type neighbors during ' num2str(x1*delta_t/60) 'hrs']);
xlim([0 1.05]); 
ylim([0 round(max(DiffC)+5)]);
ylabel(['Estimated D [um^2/hr] from initial ~ ' num2str(x1*delta_t/60) '-hrs long motion']);
[r,~]=find(isnan(frac_init));
frac_init(r) = [];
DiffC(r) = [];
cc = corrcoef((frac_init),(DiffC));
cc = cc(1,2);
title(['Total ' num2str(counter) ' uninterrupted tracks; Correlation coefficient ' num2str(cc) ]);

%% separate the msd data based on the starting fraction of sametype cells in
% the local neighborhood 
% TODO: separate these based on the start positionof the cell within the
% colony
% TODO: do the estimate of the D in time (for linear sections of the curve,
% for tracjs for which it is relevant)
close all
thresh_frac1 = 0.2;
thresh_frac2 = 0.6;
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


