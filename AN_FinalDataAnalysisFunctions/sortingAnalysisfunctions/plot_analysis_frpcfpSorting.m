%% 
% plot results from the original sorting pattern, where sstained for Bra
% and Sox2
%  dir = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/19-SORTING_onuPattern/all_Sotring_OUTFILES';
%  nms = {'sortBetaCatpluri_CFPdiff_June29th2017LiveImgCFPGFPRFPCY5'}; % peaks(5)-cfp, peaks(6)-bra, peaks(8)-gfp,peaks(10)-rfp
 
  dir = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/19-SORTING_onuPattern/all_Sotring_OUTFILES';
  nms = {'sortGFPS4cfp_70to30_cfpGfpRfpCy5'}; % peaks(5)-cfp, peaks(6)-bra, peaks(8)-gfp,peaks(10)-rfp

 % 
 cfpthresh = 1500; % 
 brathresh = 10000;% same
 thresh = [cfpthresh brathresh];
 nms2 = {'30:70 CFP(diff) GFPSmad4(pluri)'};%20:80 CFP(diff) betaCat(pluri)
dapimax = 2000; % here area thresh (high)
scaledapi = 0;
index2 = [6 8];% bra and nuc-betacat/smad4
if scaledapi == 1
 for k=1:size(nms2,2)
[dapi(k),ncells] = getmeandapi(nms(k),dir,[], dapimax);
disp(['cells found' num2str(ncells) ]);
disp(['dapi mean value' num2str(dapi(k)) ]);
end
dapiscalefactor = dapi/dapi(1);
end
if scaledapi == 0
dapiscalefactor = ones(1,size(nms,2));
end
disp(dapiscalefactor);

for k=1:size(nms,2)
        filename{k} = [dir filesep  nms{k} '.mat'];
        load(filename{k},'peaks','plate1');
        col = plate1.colonies;
[alldata,allcfp,allnoncfp,maxcolsz,frac] = getsorteddat_rfpcfpsorting_nodapi(peaks,col,index2,dapimax,thresh);%peaks,col,index2,dapimax,thresh
 
end
%save('fractionaldataesi_esiCFP_originalSort','frac','thresh');

%% now will analyze mean levels of bra in cells of a colony, dpeneding on its fractional content of cfp-pos cells
% type
% frac = struct with fields
% frac.sz
% frac.cfppos
% frac.dat
% frac.Mbra              % mean bra levels in the beta-cat cells of that colony
% frac.MSox2             % mean betaCat levels in the beta-cat cells of that colony
% frac.MbraPos           % fraction of bra positive cells out of the remaining
% frac.nuccytoratio      % mean nuc:cyto , relevant only for smad4 cells
% frac.nuccytoinCFPcell  % mean nuc:cyto in CFP cells, relevant only for
% smad4 cells % not useful if imaged on the epi (cfp excites gfp)

% cells (non cfp+)
% load('fractionaldataesi_esiCFP_originalSort.mat');
close all
alldata1 = zeros(size(frac,2),3);
allsz = cat(1,frac.sz);
allsztrue = cat(1,frac.sztrue);
allMbra = cat(1,frac.Mbra);
allMgreen = cat(1,frac.Mgreen);
alldiffFrac = cat(1,frac.cfppos);
allMbraFrac = cat(1,frac.MbraPos);
allnucCyto = cat(1,frac.nuccytoratio);
allnucCytoinCFP = cat(1,frac.nuccytoinCFPcell);
param1 ='Bra';
yl1 = 2.5;
yl2 = 50000;
titlestring = {'esiCFP with SMAD4cells pluri, July10th SDImaging'};%esiCFP with betaCat pluri, June29th SDImaging
% here select the colony size ( approx )
[sortedfrac,idx] = sort(alldiffFrac); % increasing fraction of cfp+ cells
% idx, the original row before sorting               
     figure(1), plot(sortedfrac,allMbra(idx),'p','MarkerFaceColor','m','MarkerEdgeColor','k','Markersize',18);     
     ylim([0 yl2]);box on, hold on
     figure(2), plot(sortedfrac,allMgreen(idx),'p','MarkerFaceColor','c','MarkerEdgeColor','k','Markersize',18);     
     ylim([0 10000]);box on
h = figure(1);
h.CurrentAxes.FontSize = 18;
h.CurrentAxes.LineWidth = 3;
xlabel('Fraction of CFP+(diff) cells in the colony');
ylabel(['Mean ' num2str(param1) ' in the non-CFP']);
title(titlestring);
legend('42 hours of sorting');
legend('42 hours of sorting','Location','Northwest');
param2 = 'nuc SMAD4';
h = figure(2);
h.CurrentAxes.FontSize = 18;
h.CurrentAxes.LineWidth = 3;
xlabel('Fraction of CFP+(diff) cells in the colony');
ylabel(['Mean ' num2str(param2) 'in the non-CFP']);
title(titlestring);
legend('42 hours of sorting','Location','Northwest');
% now scatter and colorcode by colony size
custmap = allsz(idx);
custmap(custmap>2500)=2500;
figure(3),scatter(sortedfrac,allMbra(idx),[],allsztrue(idx),'LineWidth',2); colorbar; ylim([0 yl2]);box on
xlabel('Fraction of CFP+(diff) cells in the colony');
ylabel(['Mean ' num2str(param1) ' in the non-CFP']);
param2 = 'nuc:cyto SMAD4';

h = figure(3);
h.Colormap = jet;
h.CurrentAxes.FontSize = 18;
h.CurrentAxes.LineWidth = 3;
title(titlestring);
[cmin cmax]=caxis;
caxis([cmin 2000])
colorbar
figure(4),scatter(sortedfrac,allnucCyto(idx),[],allsztrue(idx),'LineWidth',2); colorbar; ylim([0 yl1]); box on%custmap
xlabel('Fraction of CFP+(diff) cells in the colony');
ylabel(['Mean ' num2str(param2) ' in the non-CFP']);
h = figure(4);
h.Colormap = jet;
h.CurrentAxes.FontSize = 18;
h.CurrentAxes.LineWidth = 3;
title(titlestring);
[cmin cmax]=caxis;
caxis([cmin 2000])
colorbar

figure(5),scatter(sortedfrac,allMbraFrac(idx),[],allsztrue(idx),'LineWidth',2); colorbar; ylim([0 1]); box on
xlabel('Fraction of CFP+(diff) cells in the colony');
ylabel(['Frac ' num2str(param1) '+ cells in the non-CFP']);
h = figure(5);
h.Colormap = jet;
h.CurrentAxes.FontSize = 18;
h.CurrentAxes.LineWidth = 3;
title(titlestring);
[cmin cmax]=caxis;
caxis([cmin 2000])
colorbar

%close all
figure(6),scatter(allMbra(idx),allnucCyto(idx),[],allsztrue(idx),'LineWidth',2); colorbar; ylim([0 1]); box on; hold on
r = corrcoef(allMbra(idx),allMgreen(idx));
text(11000,9000,['Correlation coeff' num2str(r(2))],'FontSize',20,'Color','m');
ylabel(['Mean ' num2str(param2) ' in the non-CFP']);
xlabel(['Mean ' num2str(param1) ' in the non-CFP']);
h = figure(6);
h.Colormap = jet;
h.CurrentAxes.FontSize = 18;
h.CurrentAxes.LineWidth = 3;
title(titlestring);
[cmin cmax]=caxis;
caxis([cmin 2000])
colorbar
ylim([0 yl1]);
xlim([0 yl2]);





%% local neighborhood analysis, consider cells within each colony 
 close all 
 dir = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/19-SORTING_onuPattern/all_Sotring_OUTFILES';
 %nms = {'sortBetaCatpluri_CFPdiff_June29th2017LiveImgCFPGFPRFPCY5'}; %sortGFPS4cfp_70to30_cfpGfpRfpCy5  peaks(5)-cfp, peaks(6)-bra, peaks(8)-gfp,peaks(10)-rfp
 % sorted set stained with Bra and sox2
 matfile = 'sortBetaCatpluri_CFPdiff_June29th2017LiveImgCFPGFPRFPCY5.mat';
 %paramstr = {'CFP','Bra','GFPsmad4','nuc:cyto GFP'};%sortGFPS4cfp_70to30_cfpGfpRfpCy5
 paramstr = {'CFP','Bra','BetaCat'};%sortBetaCatpluri_CFPdiff_June29th2017LiveImgCFPGFPRFPCY5
 %paramstr = {'CFP','Bra','Sox2'};%sortedBetaCat_lsmimg1_merged
 cfpthresh = 1500;
 brachan =6;
 cfpchan = 5;
 greenchan = [8];
 D = 200; 
 [colonylocalstats,col] = getlocalneighbordata(matfile,cfpthresh, brachan,cfpchan,greenchan,D);
 %% 
 D = [20 40 100 200 300 400 500 600 700 800];
 bra_to_local = zeros(size(D,2),2);
 green_to_local = zeros(size(D,2),2);
 bra_to_green = zeros(size(D,2),2);
 green_to_cfpcellN = zeros(size(D,2),2);
 colonysizes = [];% if not empty, need to specify the low and high ends of colny size
 for ii=1:size(D,2);
  [colonylocalstats,col]= getlocalneighbordata(matfile,cfpthresh, brachan,cfpchan,greenchan,D(ii));
  [r1,r2,r3,r4] = getcorrwithneighborhood(colonylocalstats,colonysizes); 
  nonzeros(r4(isfinite(r4)))
  bra_to_local(ii,1) = mean(nonzeros(r2(isfinite(r2))));
  bra_to_local(ii,2) = std(nonzeros(r2(isfinite(r2))));

  green_to_local(ii,1) = mean(nonzeros(r3(isfinite(r3)))); 
  green_to_local(ii,2) = std(nonzeros(r3(isfinite(r3)))); 
  
  bra_to_green(ii,1) = mean(nonzeros(r4(isfinite(r4))));
  bra_to_green(ii,2) = std(nonzeros(r4(isfinite(r4))));
  
   green_to_cfpcellN(ii,1) = mean(nonzeros(r1(isfinite(r1))));
   green_to_cfpcellN(ii,2) = std(nonzeros(r1(isfinite(r1))));

 end
 
 %% plot correlation as a function of local neighborhood radius 
 close all
 px2micron = 0.3215;% micron per pixel
 figure(7),errorbar(bra_to_local(:,1),bra_to_local(:,2),'-p','MarkerFaceColor','c','MarkerEdgeColor','k','Markersize',15);hold on; box on
 errorbar(green_to_local(:,1),green_to_local(:,2),'-p','MarkerFaceColor','g','MarkerEdgeColor','k','Markersize',15); hold on
 errorbar(bra_to_green(:,1),bra_to_green(:,2),'-p','MarkerFaceColor','r','MarkerEdgeColor','k','Markersize',15); hold on
 errorbar(green_to_cfpcellN(:,1),green_to_cfpcellN(:,2),'-p','MarkerFaceColor','m','MarkerEdgeColor','k','Markersize',15); hold on
 %legstr(1:size(D,2))= {[num2str(D*px2micron)]};
 legend('Bra to local CFPfraction','Green to local CFPfraction','Bra to Green','Green to local CFPcellNumber');
 ylim([0 1]);
 xlim([0 size(D,2)]);
 h = figure(7);
 h.CurrentAxes.LineWidth = 3;
 h.CurrentAxes.FontSize = 18;
 title('GFP-SMAD4 cells with CFP-diff cells')
 %title('GFP-BetaCat cells with CFP-diff cells')
title('esi17 cells with CFP-diff cells');
 xlabel('Neighborhood size, um');
 ylabel('mean Correlation coefficient')
 h.CurrentAxes.XTick = [1:size(D,2)];
  h.CurrentAxes.XTickLabel = round(D*px2micron);

 %% plot the correlation cofficient for all colonies
 close all
clear braincell
clear cfpcellclose
clear cfpfracclose
 px2micron = 0.3215;% micron per pixel
colormap = jet;
% r2 - bra corelation to fraction of CFP+ in neighborhood
% r3 - green chanel corelation to fraction of CFP+ in neighborhood
% r1 - green chanel corelation to abs number of CFP+ cells in neighborhood
colonysizes = [];% if not empty, neet to specify the low and high ends of colny size
[r1,r2,r3,r4] = getcorrwithneighborhood(colonylocalstats,colonysizes); 
figure(4), histogram(nonzeros(r3),'BinWidth',0.04,'Normalization','Probability','FaceColor','r');box on ;ylim([0 1]);xlim([0 1]);xlabel('Correlation coefficient for each colony');hold on
figure(4), histogram(nonzeros(r2),'BinWidth',0.04,'Normalization','Probability','FaceColor','c');box on ;ylim([0 1]);xlim([0 1]);
ylabel('Frequency')
h = figure(4); 
h.CurrentAxes.LineWidth = 3;
h.CurrentAxes.FontSize = 18;
title('marker level in cell correlated to local frac.CFP+')
legend(paramstr{3},paramstr{2});
 
%% plot the colony-by-colony datadata
 %load('sortGFPS4cfp_70to30_cfpGfpRfpCy5.mat','peaks','plate1');%sortGFPS4cfp_70to30_cfpGfpRfpCy5   sortBetaCatpluri_CFPdiff_June29th2017LiveImgCFPGFPRFPCY5
close all
 clear r
clear braincell
clear greenincell
clear cfpfracclose
px2micron = 0.3215;% micron per pixel

% r1 = zeros(size(colonylocalstats,2),1);
% r2 = zeros(size(colonylocalstats,2),1);
% r3 = zeros(size(colonylocalstats,2),1);
 load(matfile,'peaks','plate1');%sortGFPS4cfp_70to30_cfpGfpRfpCy5   sortBetaCatpluri_CFPdiff_June29th2017LiveImgCFPGFPRFPCY5
 M = max(cat(1,plate1.colonies.ncells)); % max colony size in this dataset
considercolsz = [0 1000];
brathresh = 0;
figure(6), histogram(cat(1,col.ncells),'BinWidth',100,'FaceColor','c','Normalization','Probability');box on ;xlabel('Colony Size')
count = 0;
colormap = jet;
greennuctocyto = [];
for jj=1:size(colonylocalstats,2) % loop over colonies
 if ~isempty(colonylocalstats(jj).allstats)
braincell = cat(1,colonylocalstats(jj).allstats.braincell);
greenincell = cat(1,colonylocalstats(jj).allstats.greenincell);
if ~isempty(colonylocalstats(jj).allstats(1).nuctocyto)
greennuctocyto = cat(1,colonylocalstats(jj).allstats.nuctocyto);
end
samecellfr = cat(1,colonylocalstats(jj).allstats.pluriclosefr);
cellarea = cat(1,colonylocalstats(jj).allstats.A);
cfpcellsclose =  cat(1,colonylocalstats(jj).allstats.cfpclose);
cfpfracclose =  cat(1,colonylocalstats(jj).allstats.cfpclosefr);
xycell= cat(1,colonylocalstats(jj).allstats.currcell);
colorrand =randi(50);
colsz =  size(braincell,1);
colormap2 = cellarea;
if (colsz>considercolsz(1))  && (colsz <considercolsz(2)) % test various conditions here       
    colsz
    count = count+1;
% may consider only brapositive (braincell>brathresh)
figure(1), plot(cfpcellsclose(braincell>brathresh),braincell(braincell>brathresh),'p','MarkerEdgeColor',colormap(colorrand,:),'Markersize',15,'LineWidth',2);box on;xlabel('N CFP+ cells in cell neighborhood'); ylabel([ paramstr{2} ' level in cell']);hold on
legend(['Col sz btw ' num2str(considercolsz(1)) ' and '  num2str(considercolsz(2)) 'cells; found ' num2str(count) 'colonies']);
figure(2), scatter(cfpfracclose(braincell>brathresh),braincell(braincell>brathresh),[],colormap2,'LineWidth',2);box on;xlabel('Fraction of CFP+ cells out of neighbors'); ylabel([ paramstr{2} ' level in cell']);hold on
legend(['Col sz btw ' num2str(considercolsz(1)) ' and '  num2str(considercolsz(2)) 'cells; found ' num2str(count) 'colonies']);

figure(3), scatter(cfpfracclose(braincell>brathresh),greenincell(braincell>brathresh),[],colormap2,'LineWidth',2);box on;xlabel('Fraction of CFP+ cells out of neighbors'); ylabel([ paramstr{3} ' level in cell']);hold on
legend(['Col sz btw ' num2str(considercolsz(1)) ' and '  num2str(considercolsz(2)) 'cells; found ' num2str(count) 'colonies']);

figure(5), scatter(braincell(braincell>brathresh),greenincell(braincell>brathresh),[],cfpfracclose(braincell>brathresh),'p','LineWidth',3);box on;ylabel([ paramstr{3} ' level in cell']); xlabel([ paramstr{2} ' level in cell']);hold on
legend(['Col sz btw ' num2str(considercolsz(1)) ' and '  num2str(considercolsz(2)) 'cells; found ' num2str(count) 'colonies']);
if ~isempty(greennuctocyto)
figure(7), plot(cfpfracclose(braincell>brathresh),greennuctocyto(braincell>brathresh),'p','LineWidth',3);box on;ylabel([ paramstr{4} ' level in cell']); xlabel('Fraction of CFP+ cells out of neighbors');hold on
legend(['Col sz btw ' num2str(considercolsz(1)) ' and '  num2str(considercolsz(2)) 'cells; found ' num2str(count) 'colonies']);
 title(['Neighborhood:' num2str(D*px2micron) ' um'  ]);%' colSZ   ' num2str(colsz)

end
figure(8), scatter(samecellfr(braincell>brathresh),greenincell(braincell>brathresh),[],cfpfracclose(braincell>brathresh),'LineWidth',2);box on;xlabel('Fraction of unlabeled cells out of neighbors'); ylabel([ paramstr{3} ' level in cell']);hold on
legend(['Col sz btw ' num2str(considercolsz(1)) ' and '  num2str(considercolsz(2)) 'cells; found ' num2str(count) 'colonies']);
 end
end
end


h = figure(1);
h.CurrentAxes.LineWidth = 3;
h.CurrentAxes.FontSize = 18;
xlim([0 max(cfpcellsclose)]);
ylim([0 60000])
 title(['Neighborhood:' num2str(D*px2micron) ' um; meanCORR:' num2str(mean(r1(isfinite(nonzeros(r1))))) ]);%' colSZ   ' num2str(colsz)

h = figure(2); 
h.CurrentAxes.LineWidth = 3;
h.CurrentAxes.FontSize = 18;
colorbar
%h.Colormap = jet;
xlim([0 1.05]);
ylim([0 60000]);
title(['Neighborhood:' num2str(D*px2micron) ' um; meanCORR:' num2str(mean(r2(isfinite(nonzeros(r2)))))  ]);%' colSZ  ' num2str(colsz)

h = figure(3); 
h.CurrentAxes.LineWidth = 3;
h.CurrentAxes.FontSize = 18;
colorbar
xlim([0 1.05]);
ylim([0 60000])
title(['Neighborhood:' num2str(D*px2micron) ' um; meanCORR:' num2str(mean(r3(isfinite(nonzeros(r3)))))  ]);%' colSZ  ' num2str(colsz)

h = figure(5); 
h.CurrentAxes.LineWidth = 3;
h.CurrentAxes.FontSize = 18;
title(['Neighborhood:' num2str(D*px2micron) ' um; Colorbar local CFP fraction' ]);%' colSZ  ' num2str(colsz)
h.Colormap = jet;
colorbar

h = figure(6); 
ylabel('Frequency')
h.CurrentAxes.LineWidth = 3;
h.CurrentAxes.FontSize = 18;
title('Colony Size distribution')
h = figure(8);
h.CurrentAxes.LineWidth = 3;
h.CurrentAxes.FontSize = 18;
 title(['Neighborhood:' num2str(D*px2micron) ' um; ']);%' colSZ   ' num2str(colsz)
%% test neighborhood , pick a cell and plot its neighbors
close all
colormap = jet;
coln = jj;
for celln=1:size(colonylocalstats(coln).allstats,2)
    colorrand =1;
figure(3),plot(xycell(celln,1),xycell(celln,2),'p','MarkerFaceColor',colormap(colorrand,:),'Markersize',20,'MarkerEdgeColor','k');hold on
plot(colonylocalstats(coln).allstats(celln).nearcellstats(:,1),colonylocalstats(coln).allstats(celln).nearcellstats(:,2),'*','Color',colormap(colorrand,:),'Markersize',8);hold on
end
ylim([0 2048])
xlim([0 2048])




