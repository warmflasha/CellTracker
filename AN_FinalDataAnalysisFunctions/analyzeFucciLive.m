%% adopted analysis from microcolonies
% laser scanning data (20X) or spinning disk (20X or 40X)
%direc1 ='/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2017-04-04FUCCIlive/20170403imaging';
direc1 ='/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2017-04-26-FUCCI_live_C-B-A-Fi';

cd(direc1);
ff = readAndorDirectory(direc1);% nuc and cyto dir
fname = getAndorFileName(ff,ff.p(1),[],[],1);%(ff,pos,t,z,w);
reader = bfGetReader(fname);
tpts = reader.getSizeT;
discardarea =150; %  cell area at 20X is ~ 700 pxls
mag = 20;
chan = [0 1 2];
cellIntensity = 160;%       
rad = 1;% radius to dilate the nuclei to get the donut
tg = [];
peaks = cell(1,tpts);
positions=struct;
positions.nucmask = [];
positions.data = [];
for ii = 1:length(ff.p) 
    disp(['Movie ' int2str(ff.p(ii))]);
    nucmoviefile = getAndorFileName(ff,ff.p(ii),[],0,chan(1));   % nuc channel ( last function argument)
   %[~, cmask, nuc_p, fimg_p] = simpleSegmentationLoop(nucmoviefile,[],mag,cellIntensity,cellIntensity1);    
    %[nmask,~, nuc_p] =  getrawimageseq_bgsub(nucmoviefile,mag,cellIntensity);    
    strnuc = strsplit(nucmoviefile,direc1);    
    ifilen = [direc1 strnuc{end}(1:(end-4)) '_Simple Segmentation.h5'];%
    nmask1 = readIlastikFile(ifilen);
    nmask2 = cleanIlastikMasks(nmask1,discardarea);% area filter last argument
    %dilate the nuc masks a little, since the ilastik training for the
    %fucci was done such that the nuclearmasks are smaller than actual cell
    %nuc 
    readers = struct;
    for jj=1:(size(ff.w,2))
    readers(jj).chanels = bfGetReader(getAndorFileName(ff,ff.p(ii),[],0,chan(jj)));
    end
    
%figure, imshow(allchanels{jj},[]);

    %nmask3 = imerode(nmask2,strel('disk',1));% 
   % [cmasknew] = donutilastikoverlap(nmask,cmask1,rad);% find the overlap between the donut around nuc and the ilastic-generated masks
    peaks = [];
    for k=1:tpts%tpts % loop over time points
    %CC = [];
    %CC = regionprops(nmask2(:,:,k),'Centroid','PixelIdxList');
    %nmask_lbl = lblmask_2Dnuc(CC);
    %nmask_lbl1 = imdilate(nmask_lbl,strel('disk',1));% % this is only needed if will track each cell in time and follow its divisions
    nmask_lbl = nmask2(:,:,k); % if don't track cells, only need cleaned ilastik masks, not labeled masks
    [datacell,Lnuc] = nuconlyIlastik2data_2Dsegm(nmask_lbl,direc1,k,readers); % MAKE SURE THAT FEED IN THE IMAGES FOR ALL THE CHANNELS ALREADY
   % [datacell,Lnuc] = nuconlyIlastik2data_2Dsegm(mask1,img_nuc,direc1,ii)
    peaks{k} = datacell;  
    disp(k)
    end
    disp(['ran all time points for position' num2str(ii) ]);
    positions(ii).nucmask = Lnuc;
    positions(ii).data = peaks;
    
   % save('position15testTP8to120ansegm','positions');
   % save(['pos_' num2str(ii) 'Fucci_LSM'],'positions');
end
 save('allpositionsFucci_SD','positions');
%% plot stuff
% need to shift the CDT1 data by ~ 10 minutes ( ~ 1/3 of delat_t)
close all
load('allpositionsFucci_SD.mat');
tpt =size(positions(1).data,2);
% the last 8 frames the images get dim and notmany cells remain in focus
delta_t = 20;   
vect = ([1:10:tpt])*delta_t/60;
minA = 150;
maxA = 750;
pperwell = 10;
posvect = [1:pperwell:size(positions,2)];
colormap =colorcube;
wells = 4;
meantwo = zeros(tpt,wells);
meantwoG1 = zeros(tpt,wells);
err1 = zeros(tpt,wells);
raw = cell(1,wells);
s = 1;
LSMdelay = 0;
timeTraces = struct;
titlestr = {'Control','BMP4, 10 ng/ml','Activin, 50 ng/ml','MEK1/2 1 uM'};
C = {'o','*','+','o','*','+','o','*','+','o','*','x'};
cellstoav = cell(posvect(end),1);
for k=1:pperwell:(posvect(end))
    %disp(k:k+pperwell-1);
    q = 1;
    tmp2 = zeros(tpt,pperwell);
    tmp3 = zeros(tpt,pperwell);

    for jj=k:k+pperwell-1
        timeTraces(jj).data = zeros(tpt,4);% first col the cell area
        for ii=1:size(positions(jj).data,2)% loop over time points            
            if ~isempty(positions(jj).data{ii})
                screen = positions(jj).data{ii}(:,4);% cell areas
                [r1,~] = find(screen<minA);
                [r2,~] = find(screen>maxA);                
                positions(jj).data{ii}(cat(1,r1,r2),:) = [];
                cellstoav{jj}(ii,1) = size(positions(jj).data{ii},1);
                timeTraces(jj).data(ii,1:4) = mean(positions(jj).data{ii}(:,(4:end)),1);% mean over cells at given time point columns (area nuc,g2,g1)
                
                %figure(50+k), plot(positions(jj).data{ii}(:,6)./positions(jj).data{ii}(:,5),'g','linewidth',1);ylim([0 2]);hold on%t
               % figure(51), plot(positions(jj).data{ii}(:,7)./positions(jj).data{ii}(:,5),'r','linewidth',1);ylim([0 2]);hold on%t
                figure(k+1),plot(ii,cellstoav{jj}(ii,1),'.');hold on, ylim([100 700]);xlim([1,tpt-8]);
            end
            
        end
        %             badpoints = size(nonzeros(x),1);
        %disp(badpoints);
        tmp = (timeTraces(jj).data(:,3)./(timeTraces(jj).data(:,2)));% normalized G2  ./(timeTraces(jj).data(:,1))
        tmpG1 = (timeTraces(jj).data(:,4)./(timeTraces(jj).data(:,2)));% normalized G1  ./(timeTraces(jj).data(:,1))
        
        rawG2 = (timeTraces(jj).data(:,3));% raw G2
        rawG1 =(timeTraces(jj).data(:,4)); % raw G1
        tmp2(:,q) = tmp(:,1);
        tmp3(:,q) = tmpG1(:,1);
        q = q+1;
        disp(jj);
        tmp2;
        figure(k), plot((1:tpt)',tmp2,'g','linewidth',1,'Marker',C{1},'MarkerSize',8);ylim([0 1]);xlim([1,tpt-8]);hold on%tmp'color',colormap(k+2,:)
        figure(k), plot((1:tpt)',tmp3,'r','linewidth',1,'Marker',C{1},'MarkerSize',8);ylim([0 1]);xlim([1,tpt-8]);hold on%tmpG1
        
        h = figure(k);box on
        xlabel('time,hours');ylabel('Cell Cycle Marker');
        h1 = figure(k+1);ylabel('Number of Found cells');
        xlabel('time,hours');
        h.CurrentAxes.LineWidth = 3;h.CurrentAxes.FontSize = 15;
        h1.CurrentAxes.LineWidth = 3;h1.CurrentAxes.FontSize = 15;
        h.CurrentAxes.XTick = [1:10:tpt];
        h.CurrentAxes.XTickLabel = {round(vect)};
        h1.CurrentAxes.XTick = [1:10:tpt];
        h1.CurrentAxes.XTickLabel = {round(vect)};
        
        for idx = 1:size(posvect,2)
            if k == posvect(idx)
                figure(k),title(titlestr{idx});
                figure(k+1),title(titlestr{idx});
            end
        end
    end
    
    % size(tmp2)
    tmp2(isnan(tmp2)) = 0;
    
    for ii=1:tpt
        meantwo(ii,s) = mean(nonzeros(tmp2(ii,:)));
        err1(ii,s) = std(nonzeros(tmp2(ii,:)));
        meantwoG1(ii,s) = mean(nonzeros(tmp3(ii,:)));
        err2(ii,s) = std(nonzeros(tmp3(ii,:)));
    end
    s = s+1;
end

%%
% 
C = {'.','*','x','d'};
titlestr = {'Control','BMP4, 10 ng/ml','Activin, 50 ng/ml','MEK1/2 1 uM'};
for jj=1:size(meantwo,2)
figure(jj+4), errorbar((1:tpt-8)',meantwo(1:tpt-8,jj),err1(1:tpt-8,jj),'linewidth',2,'color','g','MarkerSize',8);box on;hold on
figure(jj+4), errorbar((1:tpt-8)',meantwoG1(1:tpt-8,jj),err2(1:tpt-8,jj),'linewidth',2,'color','r','MarkerSize',8);box on;hold on
h1 = figure(jj+4);
h1.CurrentAxes.FontSize = 15;
h1.CurrentAxes.LineWidth = 3;
ylim([0 0.65]);
title('FUCCI');
xlabel('time, hours');
ylabel('Cell Cycle Marker');
title(titlestr{jj});
vect = ([1:10:tpt])*delta_t/60;
h1.CurrentAxes.XTick = [1:10:tpt];
h1.CurrentAxes.XTickLabel = {round(vect)};
legend('G2, Geminin','G1, Cdt1','orientation','horizontal');
end


