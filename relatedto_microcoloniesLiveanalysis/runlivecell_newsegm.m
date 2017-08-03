%% get max projetions from the live cell z-images
% get nuc projections
direc = ('/Volumes/data2/Anastasiia/LiveCellImagingGFPs4RFPh2b/2015-12-31-ANuCol_10ngmlBMPDec31_20160102_54113 PM');
direc2 = ('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/12-31-2015-set_onlyinBMP/nuc_projections/');
positions = (0:18);
tg = 0;
chan = 1;
Nchoose = [];
for k=2:size(positions,2)
pos = positions(k);
 MaxProjTimeGroupsAN(direc,direc2,pos,tg,chan,Nchoose); 
end
%cyto projections
direc = ('/Volumes/data2/Anastasiia/LiveCellImagingGFPs4RFPh2b/2015-12-31-ANuCol_10ngmlBMPDec31_20160102_54113 PM');
direc2 = ('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/12-31-2015-set_onlyinBMP/cyto_projections/');
positions = (0:18);
tg = 0;
chan = 2;
Nchoose = [];
for k=2:size(positions,2)
pos = positions(k);
 MaxProjTimeGroupsAN(direc,direc2,pos,tg,chan,Nchoose);
 
end
%%
parpool(4);
%%
% Nov12 data
% direc1 ='/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/11-12-2015set/nuc_proj'; 
% direc2 = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/11-12-2015set/cyto_proj';
% Nov12 imagin set: tp = 37 and tp = 39 same cells but shofted, throw out tpt = 38 (
% completely different cells there)
toshift = 0;
matchdist = 150;% 150
shiftframe = 38;

% jan8 data time group2 (20-37 ht window)
direc1 ='/Users/warmflashlab/Desktop/JANYARY_8_DATA_ilasik/2016-11-03-jan8data_projections_tg2/nuc_projections_tg2';
direc2 ='/Users/warmflashlab/Desktop/JANYARY_8_DATA_ilasik/2016-11-03-jan8data_projections_tg2/cyto_projections_tg2';

%40X tiling2 data
% direc1 ='/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2016-07-26-Tiling2_24hrtotalBMP410ngml/uColTiling2_20hrinBMP4_20160726_24717PM/nuc_projections';
% direc2 = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2016-07-26-Tiling2_24hrtotalBMP410ngml/uColTiling2_20hrinBMP4_20160726_24717PM/cyto_projections';

% only in BMP4 data
% direc1 ='/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/12-31-2015-set_onlyinBMP/nuc_projections/';
% direc2 ='/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/12-31-2015-set_onlyinBMP/cyto_projections/';

% tiling1 data
% direc1 = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2016-07-07-LiveCellTiling_28hr10ngmlBMP4/2016-10-17-projections/nuclear';
% direc2 = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2016-07-07-LiveCellTiling_28hr10ngmlBMP4/2016-10-17-projections/cyto';

%pluri set
% direc1 = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2016-10-20-pluriset/nuc_projections/';
% direc2 = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2016-10-20-pluriset/cyto_projections/';

%Febset data
direc1 ='/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/03-02-2016-uCol_diff_AF(83tptsusable)/nuc_projections';
direc2 = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/03-02-2016-uCol_diff_AF(83tptsusable)/cyto_projections';

ff1 = readAndorDirectory(direc1);% nuc
ff2 = readAndorDirectory(direc2);% cyto
discardarea =2000; % 
mag = 60;
chan = [0,1];
cellIntensity = 300;% for pluri   280 % does not matter, since the nuc masks are from ilastik
cellIntensity1 = 100; % % jan8set timegroup2 100 %380 for feb set bright, 200-300 for dim positions % for cyto pluri 180 % 260-300 for tiling 1; 220 for nov12 set % 300 for BMP4 only set % for tiling2 set:350
tg = 2;
for ii = 30:length(ff1.p) 
    disp(['Movie ' int2str(ff1.p(ii))]);
    nucmoviefile = getAndorFileName(ff1,ff1.p(ii),2,0,0);   % nuc channel ( last function argument)
    fmoviefile = getAndorFileName(ff2,ff2.p(ii),2,0,1);     % cyto channel
    [~, cmask, nuc_p, fimg_p] = simpleSegmentationLoop(nucmoviefile,fmoviefile,mag,cellIntensity,cellIntensity1);
    stmp = strsplit(nucmoviefile,direc1);
    ifile = ['/Users/warmflashlab/Desktop/JANYARY_8_DATA_ilasik/2016-11-03-jan8data_projections_tg2/nuc_projections_tg2/' stmp{end}(2:(end-4)) '_{simplesegm}.h5'];%stmp{end-1}(2:end)
    nmask = readIlastikFile(ifile);
    nmask = cleanIlastikMasks(nmask,discardarea);% area filter last argument
    [newmasks, colonies] = statsArrayToSplitMasks(nmask,nuc_p,fimg_p,cmask,toshift,matchdist,shiftframe);
    outfile = [int2str(ff1.p(ii)) '_jan8tg2.mat'];
    saveLiveCellData(outfile,newmasks,cmask,colonies);
end
%% plot cell trajectories
trajmin =10;%10

outfile = '9_outFebsetBGan2.mat';% good positions, Feb set[0,1,3,4,5,7,8,9,10,12,14,18,21,22,24,26,27,28,29,31,32,33];

plotcelltraces(outfile,trajmin)

%%
N = 1;
for k=1:9
    figure(12), subplot(2,5,N),imshow(newmasks(:,:,k));
    subplot(2,5,N),title(num2str(k))
%     figure(13), subplot(2,5,N),imshow(cmask(:,:,k));
%     subplot(2,5,N),title(num2str(k))

    N = N+1;
end

%%
r = regionprops(newmasks(:,:,10),'Area');
r = cat(1,r.Area)




 