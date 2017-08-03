%% plot stuff from large uPatterns (ARENA EMB A)

load('sortedBetaCat_lsmimg1_A1.mat');
% use methods of colony
%load('CellsSortedonUpattern_60to40.mat');
%[rA, cellsinbin,
%dmax]=radialAverage(obj,column,ncolumn,binsize,compfrom,toohigh);
% inds1000
% inds800
% inds500
% inds200
colSZ = 500;
cols = (plate1.inds500)';
indx = [6 8];% 
%indx = [5 6 8];% cfp-cdx2 sox2 bra
res = 0.3215; % um/pxl  
param = {'Bra','gfpbetaCat'};
%param = {'CFP-Cdx2','Sox2','Bra'};
C = {'m','b','r'};
normtoixd = 5;
binsz = 50;% for 20X, this means that there are ~ 20 microns in each bin, so ~ 2 cells
compfrom = 0;% compute distance from center
dat = cell(size(cols,1),1);
celinbin = cell(size(cols,1),1);
dat2 = [];
errtoplot = [];
for jj=1:size(indx,2)
for k=1:size(cols,1)
[rA, cellsinbin, dmax]=radialAverage(plate1.colonies(cols(k)),indx(jj),normtoixd,binsz,compfrom);
dat{k}(:,jj) = rA;  % radial averages from all colonies of size N
celinbin{k}(:,jj) = cellsinbin;  % radial averages fro all colonies of size N
end
[rAmean, err] = plate1.radialAverageOverColonies(plate1.inds1000,indx(jj),normtoixd,binsz,compfrom);
dat2(:,jj) = rAmean;
errtoplot(:,jj) = err;
end
%% 
lims = length(dat2);
close all
mincellnumber = 10;
for jj=1:size(indx,2)
    
for k=1:size(dat,1)
toplot1 = dat{k}(celinbin{k}(:,jj)>mincellnumber,jj);
toplot2 = celinbin{k}(celinbin{k}(:,jj)>mincellnumber,jj);
hold on,figure(1), plot((1:size(toplot1,1))',(toplot1),'Color',C{jj});hold on
hold on,figure(2), plot((1:size(toplot1,1))',(toplot2),'r');hold on
end
figure(1), title(' expression normalized to dapi'); box on
figure(2), title(['Cells in bin, points wth less then' num2str(mincellnumber) 'cells excluded']); box on
h = figure(1);
h.CurrentAxes.LineWidth = 2;
h.CurrentAxes.FontSize = 14;
micronsMax = round(res*lims*binsz);
microndistance = (1:round(micronsMax/lims):micronsMax);%size(dat{1},1)
h.CurrentAxes.XTick = (1:3:(size(microndistance,2)));
h.CurrentAxes.XTickLabel = round(microndistance(1:3:end));
h.CurrentAxes.XLim = [1 (size(microndistance,2))];
h.CurrentAxes.YLim = [0 2];
title(['Colony diameter ' num2str(colSZ) ' microns, bin size' num2str(binsz) 'pixels']);
end
legend('Bra','gfpBetacat')

%% plot means of data with error bars
% 20X 0.3215 uM/pxl
for jj=1:size(indx,2)
toplot1 = dat2(:,jj);
figure(3), errorbar((1:size(toplot1,1))',(toplot1),errtoplot(:,jj),'Color',C{jj},'LineWidth',3);hold on

figure(3), title([num2str(param{jj}) ' Mean expression normalized to dapi']); box on
h = figure(3);
h.CurrentAxes.LineWidth = 3;
h.CurrentAxes.FontSize = 16;
xlabel('Distance from colony center, microns')
ylabel('Normalized expresion')
micronsMax = round(res*(size(toplot1,1))*binsz);
microndistance = (1:round(micronsMax/size(toplot1,1)):micronsMax);%size(dat{1},1)
h.CurrentAxes.XTick = (1:3:(size(microndistance,2)));
h.CurrentAxes.XTickLabel = round(microndistance(1:3:end));
h.CurrentAxes.XLim = [1 (size(microndistance,2))];
h.CurrentAxes.YLim = [0 2];
title(['Colony diameter ' num2str(colSZ) ' microns, bin size' num2str(binsz) 'pixels']);
end
%legend('Cdx2','nucYAP','Bra','orientation','horizontal');
legend('Bra','gfpBetacat','orientation','horizontal');

%%
% scatter plots for the colonies of different sizes

load('YAPCDX2Bra_uPattern.mat','plate1');
%%
close all 

colSZ = 1000;
vect = plate1.inds1000';
Ncol = size(vect,1);
%Ncol = 20;
idx = [6 8 10];
marker = {'Cdx2','nucYap','Bra'};
for j=1:size(idx,2)
for k=1:size(vect,1)
figure (j), colonyColorPointPlot(plate1.colonies(vect(k)),[idx(j) 5]);hold on; box on
end
figure(j),title(['Diameter ~' num2str(colSZ) 'um  Ncol=' num2str(Ncol) ' expression of ' num2str(marker{j})]);
h = figure(j);
h.CurrentAxes.LineWidth = 3;
h.CurrentAxes.FontSize = 16;
end
%% get data for the x-y scatter plots 
res = 0.3215;
N1000 = 2000; % the number of cells within the colony of this size if the colony is perfectly segmented and not split btw several images
N800 = 1300;
N500 = 700;
N200 = 140;
load('CellsSortedonUpattern_60to40.mat');
%load('YAPCDX2Bra_uPatternOldAcc.mat');
colSZ = 1000;
vect = plate1.inds1000';
Ncol = size(vect,1);
ColSzthresh = 1800;
tonorm = 0;
%idx = [6 8 10];
marker = {'CFP-Cdx2','Sox2','Bra'};
%marker = {'Cdx2','nucYap','Bra'};
idx = [5 6 8];
j1 = 3; j2 = 2;
idxtonorm1 = 5;
idxtonorm2 = 5;
cyto = 0;
if cyto == 1;
    marker = {'Cdx2','cytoYap','Bra'};
end
a1 = [];
a2 = [];
count = 0;
%for j=1:size(idx,2)
    for k=1:size(vect,1)
        if tonorm == 1
a1 = plate1.colonies(vect(k)).data(:,idx(j1))./plate1.colonies(vect(k)).data(:,idxtonorm1);
a2 = plate1.colonies(vect(k)).data(:,idx(j2))./plate1.colonies(vect(k)).data(:,idxtonorm2);
        end
        if tonorm == 0
a1 = plate1.colonies(vect(k)).data(:,idx(j1));
a2 = plate1.colonies(vect(k)).data(:,idx(j2));
        end
if (size(a1,1) < (ColSzthresh+ColSzthresh*0.1)) 
% to compute distance from celter for each cell
 coord=bsxfun(@minus,plate1.colonies(vect(k)).data(:,1:2),plate1.colonies(vect(k)).center);
 distfromcenter=sqrt(sum(coord.*coord,2)); 
figure(2), scatter(a1,a2,[],(distfromcenter*res));hold on
count = count+1;
end
    end
h = figure(2);
h.Colormap = jet;
xlabel(marker{j1});ylabel(marker{j2});
figure(2),title(['R ~' num2str(colSZ/2) 'um  Ncol=' num2str(count) 'colorcoded by dist from center' ]);
box on
h.CurrentAxes.LineWidth = 3;
h.CurrentAxes.FontSize = 16;
colorbar
%end
%% sorted cells on upattern analysis
load('sortBetaCatpluri_CFPdiff_June29th2017LiveImgCFPGFPRFPCY5.mat');%sortedBetaCat_lsmimg1_A1
colSZ = 500;
vect = plate1.inds500';
Ncol = size(vect,1);

idx = [6 8];
marker = {'Bra','betaCat'};
for j=1:size(idx,2)
    count = 0;
    for k=1:(size(vect,1))
        figure (j), colonyColorPointPlot(plate1.colonies(vect(k)),[idx(j)]);hold on; box on
        count = count+1;
    end
figure(j),title(['R ~' num2str(colSZ/2) 'um  Ncol=' num2str(count) ' expression of ' num2str(marker{j})]);
h = figure(j);
h.CurrentAxes.LineWidth = 3;
h.CurrentAxes.FontSize = 16;
end
%% look at specific colony with image
load('YAPCDX2Bra_uPatternOldAcc.mat');
%load('YAPCDX2Bra_uPattern.mat','acoords');
N = 10;
fI=getColonyImages(plate1,plate1.inds1000(N),acoords);
figure(6), imshow(fI{3},[]);
a = plate1.colonies(plate1.inds1000(N)).data(:,1:2);
figure(6), hold on, plot(a(:,1),a(:,2),'y*');
imcontrast
ncells = size(a);
disp(ncells)
N1000 = 2000;
N800 = 1300;
N500 = 700;
N200 = 140;
% 248
%% 
load('CellsSortedonUpattern_60to40.mat','acoords');%YAPCDX2Bra_uPattern
%load('YAPCDX2Bra_uPattern.mat','acoords');
N = 10;
fI=getColonyImages(plate1,664,acoords);%plate1.inds1000(N)
figure(5), imshow(fI{1},[]);
a = plate1.colonies(664).data(:,1:2);%plate1.inds1000(N)
figure(5), hold on, plot(a(:,1),a(:,2),'y*');
imcontrast
%%
mkFullCytooPlotPeaks('CellsSortedonUpattern_60to40.mat');
%% find the missing 200micron colonies witin the sorted dataset
load('sortBetaCatpluri_CFPdiff_June29th2017LiveImgCFPGFPRFPCY5.mat');%CellsSortedonUpattern_60to40

% they appear on the plot when mkfullcytoplot byt are not in the plate, but
% I can find them by image numbers or cell number ( e.g. imagenumber 248 is
% a nuce 200micron colony byt does not exist in the plate)
% same for the 100 micron colonies that are on the quadrants dividing lines
% of the chip: find them by cell number (colony size < 50 cells)
Nlow = 20; % 100 micron colonies (10-50 cells); 200 microns (55-110 cells)
Nhi = 200;
%approximate col diameter ~ 10 cells, so ~ 100 microns
colSZ = 200;
missedcols = zeros(size(plate1.colonies,2),1);
for k=1:size(plate1.colonies,2)
a = plate1.colonies(k).ncells;
if (a > Nlow) && (a < Nhi)
    disp(k)
missedcols(k,1) = k;
end
end
missed = nonzeros(missedcols);


vect = missed;
Ncol = size(vect,1);

idx = [6 8];
marker = {'Bra','betaCAT'};
for j=1:size(idx,2)
    count = 0;
    for k=1:(size(vect,1))
        figure (j), colonyColorPointPlot(plate1.colonies(vect(k)),[idx(j)]);hold on; box on
        count = count+1;
    end
figure(j),title(['R ~' num2str(colSZ/2) 'um  Ncol=' num2str(count) ' expression of ' num2str(marker{j})]);
h = figure(j);
h.CurrentAxes.LineWidth = 3;
h.CurrentAxes.FontSize = 16;
h.CurrentAxes.XLim = [-(colSZ) (colSZ)];
h.CurrentAxes.YLim = [-(colSZ) (colSZ)];
colorbar
end

% x-y scatter









