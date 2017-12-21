% function to track the sorting cells
direc1 ='C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff';
%fucci
%direc1 ='C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\Fucci_andOtherCells_regularCulture';% direc2 = 'C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIP_may2016data';
% direc_ucol = 'C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\TestTrack_uColonies';
ifile = ['C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff\SortingGFPS4cellspluri70to30_MIP_f0000_w0001_Simple Segmentation.h5'];%stmp{end-1}(2:end)
%ifile2 = ['C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIP_may2016data\LiveSortingMIP_f0007_w0001_Simple Segmentation.h5'];%stmp{end-1}(2:end)
%ifile_ucol = ['C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\TestTrack_uColonies\PluriConditions_f0021_w0000_Simple Segmentation.h5'];%stmp{end-1}(2:end)
%ifile = ['C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff\SortingGFPS4cellspluri70to30_MIP_f0000_w0001_Simple Segmentation.h5'];%stmp{end-1}(2:end)
ifile = ['C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\Fucci_andOtherCells_regularCulture\Fucci_testDynamics_MIP_f0000_w0000_Simple Segmentation.h5'];%stmp{end-1}(2:end)

tr_1 = 1;% first track ID to look at
tr_end = 100;%85 150size(tracks_t0,2) last track ID to look at, if [], all the trackIDs will be considered
tpt_end = 80; % how many timepoints to track cells for, in frames
pos = 1;%1
chan = 0;% 0 - cfp cells; 1- nuc marker of other cell type
paramfile = 'C:\Users\Nastya\Desktop\FromGithub\CellTracker\paramFiles\setUserParamTrackSortingAN_20X.m';
delta_t = 20;%15
plotsubtracks = 0;

matfile_str = trackSortingCells_full(direc1,pos,chan,ifile,paramfile,delta_t,plotsubtracks,tr_1,tr_end,tpt_end);

%% look at specific time point mask and cell centroids
totrack = 100;
if totrack>tr_end
    disp('Choose another TrackID, this exceeds the number of total tracks')
    return
end
t1 = 12;
t2 =13;
A1 = cat(1,datatomatch(t1).stats.Area);
C1 = round(cat(1,datatomatch(t1).stats.Centroid));
A1str = num2str(A1);
close all
coordintime(totrack).subtracks
if t1>size(coordintime_trackwithbreaks(totrack).dat,1)
    disp('The track was lost before this time point')
    return
end
% img_erode = imerode(datatomatch(t2).img,strel('disk',3));
figure(1), imshowpair(datatomatch(t1).img,datatomatch(t2).img,'ColorChannels','red-cyan');hold on
if isfinite(coordintime_trackwithbreaks(totrack).dat(t1,1)) && t1<= size(coordintime_trackwithbreaks(totrack).dat,1)
plot(round(coordintime_trackwithbreaks(totrack).dat(t1,1)),round(coordintime_trackwithbreaks(totrack).dat(t1,2)),'mp','Markersize',10);hold on
%text(C1(:,1)+2,C1(:,2)+2, num2str(A1str),'Color','b');
else
    disp('this cell was not found at this time point')
    plot(round(coordintime_trackwithbreaks(totrack).dat(coordintime(totrack).subtracks(1,2),1)),round(coordintime_trackwithbreaks(totrack).dat(coordintime(totrack).subtracks(1,2),2)),'cp','Markersize',8);hold on
    text(C1(:,1)+2,C1(:,2)+2, num2str(A1str),'Color','b');
end
if isfinite(coordintime_trackwithbreaks(totrack).dat(t2,1))&& t2<= size(coordintime_trackwithbreaks(totrack).dat,1)
plot(round(coordintime_trackwithbreaks(totrack).dat(t2,1)),round(coordintime_trackwithbreaks(totrack).dat(t2,2)),'bp','Markersize',8);hold on
else
    disp('this cell was not found at this time point')
    plot(round(coordintime_trackwithbreaks(totrack).dat(coordintime(totrack).subtracks(1,2),1)),round(coordintime_trackwithbreaks(totrack).dat(coordintime(totrack).subtracks(1,2),2)),'cp','Markersize',8);hold on
    
end
%% calculate and plot the cell movement stats from each continuous trajectory
% calculate MSD vs time lag and the estimate of the diffusion coefficient
% for each track
% MSD analysis is done only for continuous tracks
% bsed on movies, the 
 close all
tr_1 = 1;% first track ID to look at
tr_end = 100;
 paramfile = 'C:\Users\Nastya\Desktop\FromGithub\CellTracker\paramFiles\setUserParamTrackSortingAN_20X.m';
 delta_t = 15;
 run(paramfile)
 global userParam 
 shortesttrack = 35;%35
 colormap2 = jet;
 x1 = 10; % determines the end poin of the linear part of the curve to be used for linear fit; (1:x1)
 % MSD = 4Dt is ised to estimate the D
 [msd,slope_estimate,D,diff_coeff,mean_disp,total_disp,mean_speed,validTracks,MD,mspeed,TP,fit_out] =getCellmovement_params(coordintime,userParam.pxtomicron,delta_t,shortesttrack,tr_1,tr_end,x1);
 mean(diff_coeff)
X = max(cat(1,msd.trace_lengths));
h = figure(1);
h.CurrentAxes.XTick = (1:7:X);
h.CurrentAxes.XTickLabel = (1:7:X)*delta_t/60;
h.CurrentAxes.XLim =[0;X];
 %% save all the data into .mat file
%save('Smad4withCFPsort_testTracking_CFPchan','shortesttrack','lagtimes','diff_coeff','coordintime','msd','MD','mspeed','total_disp','-append');
%save('Smad4withCFPsort_testTracking_pluricells','shortesttrack','lagtimes','diff_coeff','coordintime','msd','MD','mspeed','total_disp','-append');
totrack = 55;
cfit = fit_out(totrack).dat;
xtofit = msd(totrack).dat(1:x1,2);
ytofit=msd(totrack).dat(1:x1,1);
figure(10),plot(cfit);hold on
plot(xtofit,ytofit,'p');hold on
text(xtofit(1)+1,ytofit(1)+1,formula(cfit));
xlabel('time,hours')
ylabel('MSD, um^2');
 
 