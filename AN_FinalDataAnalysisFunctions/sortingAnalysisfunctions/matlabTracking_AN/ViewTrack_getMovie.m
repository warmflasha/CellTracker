%% visualize the track on top of corresponding image
% TODO here: put all into the function that outputs the movie for a given
% trackID.
% TODO2: try the tracking on the non-micropetterned data, the paper smad4
% movies in regular culture or soft substrates (if I have that here)
% get the raw image data

%imagedir = 'C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\MIP_only_LiveSorting_gfpS4withCFPcells';
%imagedir = 'C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\TestTrack_uColonies';
imagedir  ='C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\Fucci_andOtherCells_regularCulture';% direc2 = 'C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIP_may2016data';
imagedir  ='C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff'
%allcellsinimg = cat(1,datatomatch(timepoint).stats.Centroid);
ff1 = readAndorDirectory(imagedir);
 pos = 1;
 chan = 0;
 nucmoviefile = getAndorFileName(ff1,ff1.p(pos),[],[],chan);%getAndorFileName(files,pos,time,z,w)
% nreader = bfGetReader(nucmoviefile);
% nt = nreader.getSizeT;
 r = bfopen(nucmoviefile);
%% set the track that want to look at and initialize movie structure
%pos = 11;
%objID =20;
celltype = 'CFP';%CFP
close all
totrack =100;
%trackcelltype_movie = struct('cdata',[],'colormap',[]);
%coordintime_trackwithbreaks = struct;
 %coordintime=coordintime_trackwithbreaks; 
size(coordintime(totrack).dat)
%coordintime(totrack).subtracks
if ~isempty(coordintime(totrack).dat)
startpt =coordintime(totrack).dat(1,3);  
endpt =coordintime(totrack).dat(end,3);% needs to be the last tracked time point
end
if isempty(coordintime(totrack).dat)
    disp('This track is empty');
end
if totrack > size(coordintime,2)
    disp('This track number exceeds the number of cells tracked');
end

 %%
 trackcelltype_movie = struct('cdata',[],'colormap',[]);
 colormap =cool ;%spring cool hsv
 nt = size(r{1},1);
 nt = 80; % segmented only 80 tpts
 randcolor = randi(size(colormap,1));
for jj=startpt:endpt% startpt:endpt
% newimg = uint8(datatomatch(jj).img); 
% allcellsinimg = cat(1,datatomatch(jj).stats.Centroid);
% rawimg = uint8(r{1}{jj});
% figure(jj),imshow(rawimg,[]);hold on

rawimg = (r{1}{jj});
figure(jj),imshow(rawimg,[500 2000]);hold on

% For now plot the rest of cells in the mask (centroids at each tp), to see how the tracking
% works (not the image, just cel coordinates
% figure(jj),plot(round(allcellsinimg(:,1)),round(allcellsinimg(:,2)),'kp','LineWidth',1,'Markersize',10,'MarkerFaceColor','b');hold on
if isfinite(coordintime(totrack).dat(jj,1)) 
figure(jj),plot(coordintime(totrack).dat(jj,1),coordintime(totrack).dat(jj,2),'rp','MarkerFaceColor',colormap(randcolor,:),'MarkerSize',8,'LineWidth',1);hold on%colormap(randcolor,:)
figure(jj),title(['Sorting' celltype 'cells;FRAME' num2str(jj)])
xlabel('image pixel coordinate')
ylabel('image pixel coordinate')
h1 = figure(jj);
% h1.RendererMode = 'manual';
% h1.Renderer = 'painters';
h1.Position =[0 0 560 420];%% this is the size that the function 'movie' supports
trackcelltype_movie(jj) = getframe(h1,h1.Position);%,[h1.Position] 
h1.Units = 'normalized';
%size(trackcelltype_movie(jj).cdata)
%figure, imshow(trackcelltype_movie(jj).cdata);
close all
end
if ~isfinite(coordintime(totrack).dat(jj,1)) 
figure(jj),title(['Sorting' celltype 'cells; This cell was lost at FRAME' num2str(jj) ]);
xlabel('image pixel coordinate')
ylabel('image pixel coordinate')
h1 = figure(jj);
h1.Position =[0 0 560 420];% this is the size that the function 'movie' supports
trackcelltype_movie(jj) = getframe(h1,h1.Position);%,[h1.Position] 
h1.Units = 'normalized';
%trackcelltype_movie(jj).colormap = colormap;
%size(trackcelltype_movie(jj).cdata)
close all
randcolor = randi(size(colormap,1));
end

end

%% run the movie
close all
h = figure(1);%h.Colormap = jet; %
movie(h,trackcelltype_movie,1,4);%,[0 0 560 420]

%% save the movie
pos1 = ff1.p(pos);
pos_video = VideoWriter(['C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\Sorting_Movie_with_CellTrack\TrackSortingCells_Movie_pos_' num2str(pos1) ' Track# ' num2str(totrack) ' CellType_' celltype '.avi']);
pos_video.FrameRate = 2;
open(pos_video);
writeVideo(pos_video,trackcelltype_movie);
close(pos_video);
