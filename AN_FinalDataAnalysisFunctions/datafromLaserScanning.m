%% read the laser scanning data or confocal data and get max projections
% save max projections
for xx =2:19;
%direc = ['/Volumes/Seagate Backup Plus Drive/RICE_Research_databackup/2017-02-13-LaserScaning4wellwithSB/FV10__20170210_141606/Track000' num2str(xx) '/'];
%direc = ['/Volumes/Seagate Backup Plus Drive/RICE_Research_databackup/20170403FucciImagingCntrBmpActWnt/Fucci_20170403/FV10__20170403_154933/Track000' num2str(xx) '/'];
direcT0 = ['/Volumes/TOSHIBAexte/2017-06-25-sortingonyPattern_LSM_betaCatpluriCFPdiff/FV10__20170623_163722/Track000' num2str(xx) '/'];
direcT1 = ['/Volumes/TOSHIBAexte/2017-06-25-sortingonyPattern_LSM_betaCatpluriCFPdiff/FV10__20170624_144519/Track000' num2str(xx) '/'];
% direcT2 = ['/Volumes/TOSHIBA EXT/lsmdata/FV10__20170522_193346/Track000' num2str(xx) '/'];
% direcT3 = ['/Volumes/TOSHIBA EXT/lsmdata2/FV10__20170523_110859/Track000' num2str(xx) '/'];
% direcT4 = ['/Volumes/TOSHIBA EXT/lsmdata2/FV10__20170523_184713/Track000' num2str(xx) '/'];

if xx>=10
direcT0 = ['/Volumes/TOSHIBAexte/2017-06-25-sortingonyPattern_LSM_betaCatpluriCFPdiff/FV10__20170623_163722/Track00' num2str(xx) '/'];
direcT1 = ['/Volumes/TOSHIBAexte/2017-06-25-sortingonyPattern_LSM_betaCatpluriCFPdiff/FV10__20170624_144519/Track00' num2str(xx) '/'];
% direcT1 = ['/Volumes/TOSHIBA EXT/lsmdata/FV10__20170522_164920/Track00' num2str(xx) '/'];
% direcT2 = ['/Volumes/TOSHIBA EXT/lsmdata/FV10__20170522_193346/Track00' num2str(xx) '/'];
% direcT3 = ['/Volumes/TOSHIBA EXT/lsmdata2/FV10__20170523_110859/Track00' num2str(xx) '/'];
% direcT4 = ['/Volumes/TOSHIBA EXT/lsmdata2/FV10__20170523_184713/Track00' num2str(xx) '/'];
end
direc2 = '/Volumes/TOSHIBAexte/2017-06-25-sortingonyPattern_LSM_betaCatpluriCFPdiff/2017-06-25-maxProjectionsbetaCatsorting';
% ff = dir(direc);
% double check this value
tpts0 =77;
tpts1 =77;
tpts2 =0;
tpts3 =0;
tpts4 =0;

fnstr1 = '_0';
fnstr2 = '_';
chan = [1 2]; % 
time = 1;
%max_img = bfMaxIntensity(reader,time,chan,bitdepth);
multitp = [];%zeros(1024,1024,tpts);

allnames = struct; 
for jj=1:size(chan,2)
    q = 0;
    qq = 0;
    fnstr1 = '_0';
    direc = direcT0;
    if xx ==2
        q = 0;
    end
    if xx ==3 || xx ==4
        q = 0;
    end
    if xx >4
        q = 0;
    end
  clear  tpname
for k=1:(tpts0+tpts1+tpts2+tpts3+tpts4)
    
    fnstr1 = '_0';
    if (k >tpts0)&& (k<=tpts0+tpts1)
       % disp('next dir1');
        direc = direcT1;
        qq = (tpts0);%
    end
    if (k >tpts0+tpts1)&& (k<=tpts0+tpts1+tpts2)
       % disp('next dir1');
        direc = direcT2;
        qq = (tpts0+tpts1);%
    end
    if (k >tpts0+tpts1+tpts2)&& (k<=tpts0+tpts1+tpts2+tpts3)
        %disp('next dir2');
        direc = direcT3;
        qq = (tpts0+tpts1+tpts2);%
    end
    if (k >tpts0+tpts1+tpts2+tpts3)&& (k<=tpts0+tpts1+tpts2+tpts3+tpts4)  
       % disp('next dir3');
        direc = direcT4;
        qq = (tpts0+tpts1+tpts2+tpts3);%
    end
     %disp(k-qq);
    if (k-qq) >=10
        fnstr1 = fnstr2;
    end
    tpname = [direc 'Image000' num2str(xx+q) fnstr1 num2str(k-qq) '.oif'];
    if xx>=10
            tpname = [direc 'Image00' num2str(xx+q) fnstr1 num2str(k-qq) '.oif'];
    end
allnames(k).tp = tpname;
reader = bfGetReader(tpname);
multitp = bfMaxIntensity(reader,time,chan(jj));
disp(['populated time point' num2str(k) 'of position' num2str(xx)]);
if (xx-1)<10
imwrite(multitp,[direc2 '/' 'sorting_betaCatpluriMIP_f000' num2str(xx-1) '_w000' num2str(chan(jj)) '.tif'],'writemode','append');
end
if (xx-1)>=10
imwrite(multitp,[direc2 '/' 'sorting_betaCatpluriMIP_f00' num2str(xx-1) '_w000' num2str(chan(jj)) '.tif'],'writemode','append');
end
end
end
disp('done')
end
%% check projections
multitp_cyto;
for k=100:110
figure(k), imshow(multitp_cyto(:,:,k),[]);
end
%% adopted analysis from microcolonies
% cytoplasmic masks are obtained from the intersection between the donuts
% round nuclei with radius rad and the ilastik-generated masks
% then the nuclei and cytos are assigned the same object number within the
% image
% the masks are applied to the raw projections and the mean intensity of
% the image without cells (mean background ) is sabed in the column 4 of
% peaks; then the signal is (nuc-bckg)/cyto-bckg);

%direc1 ='/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2017-02-03-BMP4wSB44hrs/LSConfocal20170201bmp4withSB5wells';
% feb10 data
%direc1 ='/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2017-02-10-BMP4wellwithSB39hrs';
direc1 ='/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2017-02-10-BMP4wellwithSB39hrs/inBMP4';
%direc2 = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2017-02-03-BMP4wSB44hrs/LSConfocal20170201bmp4withSB5wells';
tpts = 120;
ff = readAndorDirectory(direc1);% nuc and cyto dir
discardarea =400; %  cell area at 20X is ~ 700 pxls
mag = 20;
chan = [0,1];
cellIntensity = 150;%       300: for the Feb3set
cellIntensity1 = 110; %     350: for the Feb3set
rad = 7;% radius to dilate the nuclei to get the donut
tg = [];
peaks = cell(1,tpts);
positions=struct;
positions.nucmask = [];
positions.cytomask = [];
positions.data = [];
for ii = 15%1:length(ff.p) 
    disp(['Movie ' int2str(ff.p(ii))]);
    nucmoviefile = getAndorFileName(ff,ff.p(ii),[],0,0);   % nuc channel ( last function argument)
    fmoviefile = getAndorFileName(ff,ff.p(ii),[],0,1);     % cyto channel
    [~, cmask, nuc_p, fimg_p] = simpleSegmentationLoop(nucmoviefile,fmoviefile,mag,cellIntensity,cellIntensity1);    
    strnuc = strsplit(nucmoviefile,direc1);    
    strcyto = strsplit(fmoviefile,direc1);
    ifilen = [direc1 strnuc{end}(1:(end-5)) '_Simple Segmentation.h5'];%
    ifilec = [direc1 strcyto{end}(1:(end-5)) '_Simple Segmentation.h5'];%
    nmask1 = readIlastikFile(ifilen);
    cmask1 = readIlastikFile(ifilec);
    nmask = cleanIlastikMasks(nmask1,discardarea);% area filter last argument
    [cmasknew] = donutilastikoverlap(nmask,cmask1,rad);% find the overlap between the donut around nuc and the ilastic-generated masks
    peaks = [];
    for k=1:tpts % loop over time points
    CC = [];
    CC = regionprops(nmask(:,:,k),'Centroid','PixelIdxList');
    nmask_lbl = lblmask_2Dnuc(CC);   
    cmask_lbl = GetVoronoiCells2D(nmask_lbl,cmasknew(:,:,k)); %label the same separate cytos
    [datacell,Lnuc,Lcytofin] = laserscanningOutdat(nmask_lbl,cmask_lbl,nuc_p(:,:,k),fimg_p(:,:,k));%fimg_p
    peaks{k} = datacell;  
    disp(k)
    end
    disp(['ran all time points for position' num2str(ii) ]);
    positions(ii).nucmask = Lnuc;
    positions(ii).cytomask = Lcytofin; 
    positions(ii).data = peaks;
    
   % save('position15testTP8to120ansegm','positions');
 end
save('pos_Feb10dataTP8to120_pos14test','peaks');
%% test
for k=1:10
figure(k), subplot(1,2,1),imshow(positions(15).nucmask,[]);subplot(1,2,2),imshow(positions(15).cytomask,[]);hold on
plot(peaks{k}(:,1),peaks{k}(:,2),'r*');
r(k) = mean(peaks{k}(:,6)./peaks{k}(:,7));

end
%%
%load('pos_Feb10dataTP1to7.mat');
load('pos_Feb10dataTP8to120.mat');
wells = 4;
ptsperwell = 4;

for jj=1:size(positions,2)    
for k=1:size(positions(jj).data,2) % loop over time points within a position
   % r(k) = mean(positions(jj).data{k}(:,6)-positions(jj).data{k}(:,4))./mean(positions(jj).data{k}(:,7)-positions(jj).data{k}(:,4));
     r(k) = mean(positions(jj).data{k}(:,6))./mean(positions(jj).data{k}(:,7));

end
end
figure(2),plot((1:size(r,2))',r','*r','Markersize',8,'LineWidth',3);
ylim([0.6 1.4]);
h = figure(2);
h.CurrentAxes.LineWidth = 3;
h.CurrentAxes.FontSize = 16;
title('position 1, no BMP4')
%% plot the live cell analysis , AN code to get the nuc:cyto
%load('pos_Feb10dataTP1to7.mat');
load('position15testTP8to120ansegm.mat');
tpt = size(positions(1).data,2);
fr_stim = 1;
delta_t = 22;   %
pperwell = 1;
posvect = [1:pperwell:size(positions,2)];
a= zeros(tpt,posvect(end));
colormap = prism;
wells = 1;
meantwo = zeros(tpt,wells);
raw = cell(1,wells);
s = 1;
for k=1:pperwell:(posvect(end))
    %disp(k:k+pperwell-1);
    q = 1;
    tmp2 = zeros(tpt,pperwell);
    
    for jj=k:k+pperwell-1
        tmp3 = zeros(tpt,1);
        for ii=1:size(positions(jj).data,2)
            x = isnan(positions(jj).data{ii}(:,6));
            badpoints = size(nonzeros(x),1);
            %disp(badpoints);
            if ~isempty(positions(jj).data{ii}) && (badpoints<5) % round(tpt/10)if the trace is nonempty and the number of Nans in the traceis less then a tenth of a full trace
                tmp = mean((positions(jj).data{ii}(:,6))./(positions(jj).data{ii}(:,7)));      % mean over found cells
                tmp3(ii,1) = tmp;
                tmp2(:,q) = tmp3(:,1);
               q = q+1;
            end
        end
        figure(k), hold on, plot(tmp3,'-','color',colormap(k+1,:),'linewidth',3);ylim([0.3 1.4]);box on%title(num2str(conditions{k}));
        %a(:,jj) = (positions(jj).data{ii}(:,6) - positions(jj).data{ii}(:,4))./(positions(jj).data{ii}(:,7) - positions(jj).data{ii}(:,4));
    end
    tmp2(tmp2<0.4) = 0; % clean outliers
    tmp2(tmp2>1.5) = 0;  % clean outliers
    tmp2(isnan(tmp2)) = 0;
    for ii=1:tpt
        meantwo(ii,s) = mean(nonzeros(tmp2(ii,:)));
    end
    s = s+1;
end

%%
% to plot dose response to bmp4 use meantwo
C = {'b','m','g','r'};
for jj=1:size(meantwo,2)
figure(8), plot(meantwo(:,jj),'linewidth',3,'color',C{jj});box on;hold on
end
h1 = figure(8);
h1.CurrentAxes.FontSize = 15;
h1.CurrentAxes.LineWidth = 3;
ylim([0.3 1.3]);
title('with 10 uM SB');
xlabel('time, hours');
ylabel('Smad4 nuc:cyto');
vect = ([1:10:tpt])*delta_t/60;
vect = ([1:tpt])*delta_t/60;
h1.CurrentAxes.XTick = [1:tpt];
h1.CurrentAxes.XTickLabel = {(vect)};
legend('0 bmp','1 bmp ','3 bmp ','10 bmp ','Location','southeast')
