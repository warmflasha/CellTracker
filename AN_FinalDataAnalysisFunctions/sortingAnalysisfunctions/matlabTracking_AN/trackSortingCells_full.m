function matfile_str = trackSortingCells_full(direc1,pos,chan,ifile,paramfile,delta_t,plotsubtracks,tr_1,tr_end,tpt_end)

run(paramfile)
global userParam 
[nmask,datatomatch] = getdatatotrack(direc1,pos,chan,userParam.arealow,ifile);
ff2 = readAndorDirectory(direc1);
imshowpair(datatomatch(1).img,datatomatch(2).img,'ColorChannels','red-cyan');
tpt = 2;
clear tracks_t0
tracks_t0 = init_tracks(userParam.minpxloverlap,userParam.maxdist_tomove,datatomatch,tpt);
% now the cell are assigned track number, need to keep this number with the
% cell
tracks_all = track_celltypeAN(userParam.minpxloverlap,userParam.maxdist_tomove,tracks_t0,tr_1,tr_end,tpt_end,tpt,datatomatch);
[coordintime,coordintime_subtracks,coordintime_merged,coordintime_trackwithbreaks]=assemble_tracks(userParam.plottracks,tr_1,tr_end,delta_t,tracks_all,datatomatch,userParam.allowedgap);
if plotsubtracks
for jj=1:size(coordintime_subtracks,2)
    if ~isempty(coordintime_subtracks(jj).dat) %&& size(coordintime_subtracks(jj).dat,1)>20
    figure(10), plot(coordintime_subtracks(jj).dat(:,5),coordintime_subtracks(jj).dat(:,1));hold on 
    xlim([0 tpt_end])
xlabel('frames')
ylabel('X-coord')
title('Subtracks')
    end
end
end
if ff2.p(pos)<10
    disp('Saved to matfile')
    matfile_str = ['Tracks_' ff2.prefix '_w000' num2str(chan) '_f000' num2str(ff2.p(pos)) '.mat'];
    save(['Tracks_' ff2.prefix '_w000' num2str(chan) '_f000' num2str(ff2.p(pos)) ],'datatomatch','coordintime','coordintime_subtracks','coordintime_merged','coordintime_trackwithbreaks','delta_t','tracks_all','matfile_str','tr_1','tr_end','tpt_end');
end
if ff2.p(pos)>=10
    disp('Saved to matfile')
    matfile_str = ['Tracks_' ff2.prefix '_w000' num2str(chan) '_f00' num2str(ff2.p(pos)) '.mat' ];
    save(['Tracks_' ff2.prefix '_w000' num2str(chan) '_f00' num2str(ff2.p(pos)) ],'datatomatch','coordintime','coordintime_subtracks','coordintime_merged','coordintime_trackwithbreaks','delta_t','tracks_all','matfile_str','tr_1','tr_end','tpt_end');
end

end