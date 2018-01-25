%% select specific position and plot the signaling levels vs time for this position
% make sure o have the Idse folder with on the path, otherwise the
% positions struct is not recoglized
%$ here only one cell type is considered (the type that was assigned to cells with the gfp/rfp markers)
close all
load('/Volumes/TOSHIBAexte/2017-07-14-Smad4sorting_maxProjections/SortingGFPsmad4_esiCFP.mat');% the output .mat file of the Idse's analysis code, with the 'positions' containing all the data
pos = 14;
tpt = positions(pos).tPerFile;
delta_t = 15;   % time interval between images in live cell (in minutes)
colormap =jet;
for jj=pos 
    bg = positions(jj).timeTraces.background;%
    for ii=1:size(positions(jj).cellData,2)% ii loops over time points
       
        if ~isempty(positions(jj).cellData)
            rmbg = ones(size(positions(jj).cellData(ii).nucLevel))*bg(ii);% get bg vector; it is different for each time point
            tmp = (positions(jj).cellData(ii).nucLevel(:,1)-rmbg)./(positions(jj).cellData(ii).cytLevel(:,1)-rmbg); % subtrct bg from nuc and cyto green levels
            %
            figure(jj), hold on, plot(ii*ones(size(positions(jj).cellData(ii).nucLevel(:,1))),tmp ,'p','color',colormap(10,:),'linewidth',1);ylim([0.2 2]);box on%
            h = figure(jj);
            title(['Sorting experiment, GFP-SMAD4 cells at each time point']);xlabel('time,hours');ylabel('nuc:cyto');
            h.CurrentAxes.LineWidth = 3;h.CurrentAxes.FontSize = 15;   
            h.CurrentAxes.XTick = [1:10:size(positions(jj).cellData,2)];
            v = [1:10:size(positions(jj).cellData,2)];
            h.CurrentAxes.XTickLabel = round(v*delta_t/60);
        end
    end
end
% overlap this data onto movie (colorcode the smad4 cells by their value of
% smad4 nuc:cyto ratio) at each time point
%%  get the data separately for each colony
close all

matfile = '/Volumes/TOSHIBAexte/2017-07-14-Smad4sorting_maxProjections/SortingGFPsmad4_esiCFP.mat';
% group these into colonies first then consider each colony separately?
paramfile = '/Users/warmflashlab/CellTracker/paramFiles/setUserParamAN20X_var.m' ;
%userParam.colonygrouping = 100 (pixels);% set this parameter within the paramfile,
%depending on the colony size that is being considered 
run(paramfile)
pos = 6;%6 8  % 9 - troubleshoot

 direc1 ='/Volumes/TOSHIBAexte/2017-07-14-Smad4sorting_maxProjections/';
ff1 = readAndorDirectory(direc1);% nuc
chan = 1;% 0 - cfp cells; 1- nuc marker of other cell type
nucmoviefile = getAndorFileName(ff1,ff1.p(pos),2,0,chan);  
nreader = bfGetReader(nucmoviefile);
nt = nreader.getSizeT;
 for jj=pos
     % get the mask with colonies
        % iplane = nreader.getIndex(0,0,ii-1)+1;
        % nuc = bfGetPlane(nreader,iplane); 
    stmp = strsplit(nucmoviefile,direc1);
    ifile = [direc1 stmp{end}(1:(end-4)) '_Simple Segmentation.h5'];%stmp{end-1}(2:end)
    nmask = readIlastikFile(ifile);
    %---------------------- look at the first time point and make colony masks with
     %assigned static colony numbers   
     ti = 1;% initial time point
     statstmp = regionprops(nmask(:,:,ti),'Area','Centroid','PixelIdxList');
     A = cat(1,statstmp.Area);
     % get rid of the giant dust particle trace on the image
     [badindxlow,~] = find(A<100);
     [badindxhigh,~] = find(A>390);%390
     torm = cat(1,badindxlow,badindxhigh);    
     % make those pixels black in the image
     pixels = cat(1,statstmp(torm).PixelIdxList);
     I = nmask(:,:,ti);
     I(pixels) = false; % this image does not have junk, only cells     
     statstmp1 = regionprops(I,'Centroid','PixelIdxList','A');
%      A = cat(1,statstmp1.Area);
%      xy = cat(1,statstmp1.Centroid);
%      figure(3),imshow(I); hold on
%      plot(xy(:,1),xy(:,2),'pr');hold on
%      text(xy(:,1)+5,xy(:,2)+5,num2str(A),'Color','m');hold on     
     dilim = imdilate(I,strel('disk',60));
     dilmask = imfill(dilim,'holes');  
     
     % figure, imshow(dilmask);
     % look at the fist time point
     tpts = 1;%nt-1
     [coloniesintime,lbl_mask] = assigncellstosamecolonyintime(dilmask,pos,matfile,paramfile,tpts);% new function 
     imshowpair(lbl_mask,I);
     figure, imshow(lbl_mask);
     
     % if good run all time points
      tpts = nt-1;%nt-1
     [coloniesintime,lbl_mask] = assigncellstosamecolonyintime(dilmask,pos,matfile,paramfile,tpts);% new function 
     
   %coloniesintime(1).alltimes(1).data % the last index number is the
   %colony ID.The first index is the time point number
      
    
 end
 
 %% plot data for colonies in the image separately
 close all
 delta_t = 15;
 C = {'r','c','m','b','g','r','c','m'};
 colcenter = zeros(size(coloniesintime,2),2);
 meansignal=zeros(size(coloniesintime,2),1);
 toplot = struct;
 colszdyn = zeros(size(coloniesintime,2),size(coloniesintime(1).alltimes,2));
 for colN = 1:size(coloniesintime(1).alltimes,2);% loop over colonies in the image
     for j=1:size(coloniesintime,2)
         if ~isempty(coloniesintime(j).alltimes(colN).data)
         figure(colN), plot(j,nonzeros(coloniesintime(j).alltimes(colN).data(:,3)),'p','Color',C{colN},'Markersize',15);hold on; ylim([0 2]);
         colszdyn(j,colN) = size(nonzeros(coloniesintime(j).alltimes(colN).data(:,3)),1);
         box on
         colcenter(j,1) = mean(nonzeros(coloniesintime(j).alltimes(colN).data(:,1)));
         colcenter(j,2) = mean(nonzeros(coloniesintime(j).alltimes(colN).data(:,2)));
         %meansignal(j,1)=mean(nonzeros(coloniesintime(j).alltimes(colN).data(:,3)));
         end
     end
     h = figure(colN);
     h.CurrentAxes.LineWidth = 3;
     h.CurrentAxes.FontSize = 20;
     h.CurrentAxes.XTick = (1:15:nt);
     h.CurrentAxes.XTickLabel = round((1:15:nt)*(delta_t/60));
     
     ylabel('nuc:cyto ratio')
     xlabel('time, hours');
     
     title(['only GFP-S4 cells, colony' num2str(colN)])
     % show image of the colony with the colony center at each time point
     kk = 1;  % tp
     iplane = nreader.getIndex(0,0,kk-1)+1;
     nuc = bfGetPlane(nreader,iplane);
     toplot(colN).dat = colcenter;
     figure(1+size(coloniesintime(1).alltimes,2)), subplot(2,2,colN),imshow(imadjust(nuc,stretchlim(nuc)),[]);hold on
     figure(1+size(coloniesintime(1).alltimes,2)), subplot(2,2,colN), plot(round(toplot(colN).dat(:,1)),round(toplot(colN).dat(:,2)),'p','Markersize',25,'MarkerEdgeColor','k','MarkerFaceColor',C{colN},'LineWidth',2);hold on
     title(num2str(colN));
 end
 for j=1:size(coloniesintime(1).alltimes,2);% loop over colonies in the image
     figure(10),plot(colszdyn(:,j),'Color',C{j},'LineWidth',3);hold on
     ylim([0 100]);
     h = figure(10);
     h.CurrentAxes.LineWidth = 3;
     h.CurrentAxes.FontSize = 15;
     h.CurrentAxes.XTick = (1:15:size(coloniesintime,2));
     h.CurrentAxes.XTickLabel = round((1:15:size(coloniesintime,2))*(delta_t/60));
     ylabel('Number of cells in the colony')
     xlabel('time, hours')
 end
% TO DO: add the cfp cells 

%% get the centroids of the cfp-labeled cells (or other cells, different from the first script here) for each position so that can plot them on the scatter movies
% do only once for all positions and then save into a .mat file
% the line that saves this is below, commented out
% need to have ilstik simple segmentation masks for this
ff = readAndorDirectory('/Volumes/TOSHIBAexte/2017-07-14-Smad4sorting_maxProjections');
xy_pos = struct;
positions2 = struct;
for pos = 1:size(ff.p,2)
    
    fnm = getAndorFileName(ff,ff.p(pos),2,0,0);   % nuc channel ( last function argument)
    nreader = bfGetReader(fnm);
    maxtp = nreader.getSizeT;
    nmask = readIlastikFile([fnm(1:end-4) '_Simple Segmentation.h5']);
    for tp = 1:maxtp;
        r = regionprops(nmask(:,:,tp),'Centroid');
        xy_pos(tp).XY = cat(1,r.Centroid);
    end
    positions2(pos).dat = xy_pos;
end
%save('/Volumes/TOSHIBAexte/2017-07-14-Smad4sorting_maxProjections/Coordinates_cfpcells.mat', 'positions2');
%% make intensity color-coded movies
load('/Volumes/TOSHIBAexte/2017-07-14-Smad4sorting_maxProjections/SortingGFPsmad4_esiCFP.mat'); % info on signaling of cell type 1, with the rfp/gfp markers
load('/Volumes/TOSHIBAexte/2017-07-14-Smad4sorting_maxProjections/Coordinates_cfpcells.mat')    % info on cell type 2, with the cfp marker (only the coordinates of those cells)
pxtomicron = 0.325; % SD confocal 20X
pos = 17;
%close all
% ff = readAndorDirectory('/Volumes/TOSHIBAexte/2017-07-14-Smad4sorting_maxProjections');% 
% filenm = getAndorFileName(ff,ff.p(pos),2,0,1);   % nuc channel ( last function argument) 
% filenm2 = getAndorFileName(ff,ff.p(pos),2,0,0);
% nreader = bfGetReader(filenm);
% maxtp = nreader.getSizeT;
 %nmask = readIlastikFile([filenm(1:end-4) '_Simple Segmentation.h5']);
%
gfpintensitymovie = struct('cdata',[],'colormap',[]);
jj = pos;close all
for ii=1%:(size(positions(jj).cellData,2)-1)%  over time points
 if ~isempty(positions(jj).cellData) %&& ~isempty(nmask(:,:,ii))
            rmbg = ones(size(positions(jj).cellData(ii).nucLevel))*bg(ii);% bg is different for each time point
            tmp = (positions(jj).cellData(ii).nucLevel(:,1)-rmbg)./(positions(jj).cellData(ii).cytLevel(:,1)-rmbg);           
            othercellcoord = positions2(jj).dat(ii).XY;     
            dat = cat(2,positions(jj).cellData(ii).XY,tmp);            
            % will just save the scatter plots colorcoded by nuc:smad4 ratio
            % ,imshow(tmpimg1),hold on,
            figure(ii),  scatter((dat((isfinite(tmp)),1)),(dat((isfinite(tmp)),2)),[],tmp(isfinite(tmp)),'LineWidth',3);h = figure(ii); h.Colormap = jet; box on; hold on
            figure(ii), plot(othercellcoord(:,1),othercellcoord(:,2),'p','Markersize',10,'MarkerFaceColor','k','MarkerEdgeColor','k');
            [cmin cmax]=caxis;
            caxis([0.5 1.5]) % typical limits for the nuc:cyto smad4 ratio
            colorbar
            xlim([0 1024]);ylim([0 1024]);   % pixels
            title('Colorcode: nuc:cyto SMAD4, CFP cells - stars');
            h.CurrentAxes.FontSize = 20;h.CurrentAxes.LineWidth = 3;xlabel('pixels');
            ylabel('pixels');
            gfpintensitymovie(ii) = getframe(figure(ii));
 close all

 end
end
%% play the movie
% and then write the movie
close all
h = figure(1);h.Colormap = jet; %
movie(h,gfpintensitymovie,1,10);% last argment: frame rate
% for some frames the colormap data (cdata) is not the same dimention as
% the rest of the time points,then unable to write the movie
% remove those frames here in lines below
rr = [];
for k=1:size(gfpintensitymovie,2)
rr(k,1) = size(gfpintensitymovie(k).cdata,1);
end
[rr1,~] = find((rr<rr(1)));

gfpintensitymovie(rr1) = [];
close all
h = figure(1);h.Colormap = jet; 
movie(h,gfpintensitymovie,1,7);

% and then write the movie, uncomment writeVideo()

pos_video = VideoWriter(['Smad4_intMovie_pos' num2str(pos) '.avi']);
pos_video.FrameRate = 7;
open(pos_video);
%writeVideo(pos_video,gfpintensitymovie);
close(pos_video);


%%
