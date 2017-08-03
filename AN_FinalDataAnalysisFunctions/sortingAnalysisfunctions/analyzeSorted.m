%% analyzeSorted
%-----combine data from several imaging areas, if exists

%     pl1 = load('sortedBetaCat_lsmimg1_A1','plate1');         
%     pl2 = load('sortedBetaCat_lsmimg1_A2','plate1');         
%     newcol = [pl1.plate1.colonies,pl2.plate1.colonies];
%     plate1.colonies = newcol;
%     peaks1 = load('sortedBetaCat_lsmimg1_A1','peaks');        
%     peaks2= load('sortedBetaCat_lsmimg1_A2','peaks');         
%     newpeaks = [peaks1.peaks,peaks2.peaks];
%     peaks = newpeaks;%     
%     save('sortedBetaCat_lsmimg1_merged','plate1','peaks');  %           
 %----- 
 dir = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/19-SORTING_onuPattern/all_Sotring_OUTFILES';
 nms = {'sortedBetaCat_lsmimg1_merged'}; 
 % sorted set stained with Bra and DAPI (beta cat cells)
 dapithresh = 2000; % btacat cells are positive for blue && red (nuc) >dapithresh && > rfpthresh
 rfpthresh = 900;
 gfpthresh = 5000;  % cfp cells are positive for blue && green (nuc)   >dapithresh && > gfpthresh
 brathresh =4;% ratio to dapi
 thresh = [dapithresh rfpthresh gfpthresh brathresh];
 nms2 = {'20:80 CFP(diff) betaCat(pluri)'};
param1 = 'Beta cat';
param2 = 'Bra';
index2 = [8 6];% ordering in peaks: (5)dapi (6)cy5(bra) gfp(betacat) rfp(nucmarker)
%index2 = [6 8];
dapimax = 2000; % here area thresh (high)
toplot = cell(1,size(nms,2));
largestcolony= cell(1,size(nms,2));
flag = 0;% generate third column with the col size
flag2 = 1;% do not normalize to DAPI if flag == 0;
normto = 5;
scaledapi = 0;
% N =80;% look at only colonies with  N cells (+- 30%)
if scaledapi == 1
 for k=1:size(nms2,2)
[dapi(k),ncells] = getmeandapi(nms(k),dir,normto, dapimax);
disp(['cells found' num2str(ncells) ]);
disp(['dapi mean value' num2str(dapi(k)) ]);
end
dapiscalefactor = dapi/dapi(1);
end
if scaledapi == 0
dapiscalefactor = ones(1,size(nms,2));
end
disp(dapiscalefactor);
clear toplot

for k=1:size(nms,2)
        filename{k} = [dir filesep  nms{k} '.mat'];
        load(filename{k},'peaks','plate1');
        col = plate1.colonies;
[alldata,allcfp,allbetacat,maxcolsz,frac] = getdat_scatterLargeColonies(peaks,col,index2,flag,flag2,dapimax,dapiscalefactor,thresh);
 toplot{k} = alldata;
 largestcolony{k} = maxcolsz; % needed to resale the colormap for colony sizes
end
%save('fractionaldataBetacatCFP_sort1','frac','dapithresh','rfpthresh','gfpthresh');
%% now will analyze mean levels of bra in cells of a colony, dpeneding on its fractional content of cfp-pos cells
% type
%frac = struct with fields
% frac.sz
% frac.cfppos
% frac.dat
% frac.Mbra        % mean bra levels in the beta-cat cells of that colony
% frac.Mbetacat    % mean betaCat levels in the beta-cat cells of that colony
% frac.MbraPos    % bra+ fraction
%load('fractionaldataBetacatCFP_sort1.mat');
close all
alldata1 = zeros(size(frac,2),3);
allsz = cat(1,frac.sz);
allsztrue = cat(1,frac.sztrue);
allMbra = cat(1,frac.Mbra);
allMbetacat = cat(1,frac.Mbetacat);
alldiffFrac = cat(1,frac.cfppos);
allbrafrac = cat(1,frac.MbraPos);

index = [6 8];
param1 ='Bra';
param2 = 'nucBetaCat';
% here select the colony size ( approx )
[sortedfrac,idx] = sort(alldiffFrac); % increasing fraction of cfp+ cells
% idx, the original row before sorting               
     figure(1), plot(sortedfrac,allMbra(idx),'p','MarkerFaceColor','m','MarkerEdgeColor','k','Markersize',18);     
     ylim([0 10]);box on
     figure(2), plot(sortedfrac,allMbetacat(idx),'p','MarkerFaceColor','c','MarkerEdgeColor','k','Markersize',18);     
     ylim([0 2]);box on

h = figure(1);
h.CurrentAxes.FontSize = 20;
h.CurrentAxes.LineWidth = 3;
xlabel('Fraction of CFP+(diff) cells in the colony');
ylabel(['Mean ' num2str(param1) ' in other cells']);
title('BetaCat cells Sorted,imaging LSM, June 23');
legend('42 hours of sorting');
legend('42 hours of sorting','Location','Northwest');

h = figure(2);
h.CurrentAxes.FontSize = 20;
h.CurrentAxes.LineWidth = 3;
xlabel('Fraction of CFP+(diff) cells in the colony');
ylabel(['Mean ' num2str(param2) 'in the remaining cells']);
title('BetaCat cells Sorted,imaging LSM, June 23');
legend('42 hours of sorting','Location','Northwest');
% now scatter and colorcode by colony size
custmap = allsz(idx);
custmap(custmap>1500)=1500;
figure(3),scatter(sortedfrac,allMbra(idx),[],allsztrue,'LineWidth',2); colorbar; ylim([0 10]);box on
xlabel('Fraction of CFP+(diff) cells in the colony');
ylabel(['Mean ' num2str(param1) ' in other cells']);
h = figure(3);
h.Colormap = jet;
h.CurrentAxes.FontSize = 20;
h.CurrentAxes.LineWidth = 3;
title('BetaCat cells Sorted,imaging LSM, June 23');
[cmin cmax]=caxis;
caxis([cmin 2000])
colorbar

figure(4),scatter(sortedfrac,allMbetacat(idx),[],allsztrue,'LineWidth',2); colorbar; ylim([0 2]); box on
xlabel('Fraction of CFP+(diff) cells in the colony');
ylabel(['Mean ' num2str(param2) ' in other cells']);
h = figure(4);
h.Colormap = jet;
h.CurrentAxes.FontSize = 20;
h.CurrentAxes.LineWidth = 3;
title('BetaCat cells Sorted,imaging LSM, June 23');
[cmin cmax]=caxis;
caxis([cmin 2000])
colorbar

figure(5),scatter(sortedfrac,allbrafrac(idx),[],allsztrue,'LineWidth',2); colorbar; ylim([0 1]);box on
xlabel('Fraction of CFP+(diff) cells in the colony');
ylabel(['Fraction ' num2str(param1) '+ cells of nonCFP']);
h = figure(5);
h.Colormap = jet;
h.CurrentAxes.FontSize = 20;
h.CurrentAxes.LineWidth = 3;
[cmin cmax]=caxis;
caxis([cmin 2000])
colorbar
title('BetaCat cells Sorted,imaging LSM, June 23');
