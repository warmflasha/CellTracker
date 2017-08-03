%% 
% plot results from the original sorting pattern, where sstained for Bra
% and Sox2
 dir = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/19-SORTING_onuPattern/all_Sotring_OUTFILES';
 nms = {'originalSort_60to40cfpsox2bra'}; 
 % sorted set stained with Bra and sox2
 cfpthresh = 1500; % 
 brathresh = 2000;
 thresh = [cfpthresh brathresh];
 nms2 = {'40:60 CFP(diff) esi(pluri)'};
dapimax = 2000; % here area thresh (high)
flag = 0;% generate third column with the col size
flag2 = 1;% do not normalize to DAPI if flag == 0;
normto = 5;
scaledapi = 0;
index2 = [6 8];
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
[alldata,allcfp,allnoncfp,maxcolsz,frac] = getsorteddat_nodapi(peaks,col,index2,dapimax,thresh);%peaks,col,index2,dapimax,thresh
 
end
%save('fractionaldataesi_esiCFP_originalSort','frac','thresh');

%% now will analyze mean levels of bra in cells of a colony, dpeneding on its fractional content of cfp-pos cells
% type
% frac = struct with fields
% frac.sz
% frac.cfppos
% frac.dat
% frac.Mbra        % mean bra levels in the beta-cat cells of that colony
% frac.MSox2       % mean betaCat levels in the beta-cat cells of that colony
% frac.MbraPos     % fraction of bra positive cells out of the remaining
% cells (non cfp+)
% load('fractionaldataesi_esiCFP_originalSort.mat');
close all
alldata1 = zeros(size(frac,2),3);
allsz = cat(1,frac.sz);
allsztrue = cat(1,frac.sztrue);
allMbra = cat(1,frac.Mbra);
allMsox2 = cat(1,frac.MSox2);
alldiffFrac = cat(1,frac.cfppos);
allMbraFrac = cat(1,frac.MbraPos);
param1 ='Bra';
param2 = 'Sox2';
yl1 = 50000;
yl2 = 20000;
% here select the colony size ( approx )
[sortedfrac,idx] = sort(alldiffFrac); % increasing fraction of cfp+ cells
% idx, the original row before sorting               
     figure(1), plot(sortedfrac,allMbra(idx),'p','MarkerFaceColor','m','MarkerEdgeColor','k','Markersize',18);     
     ylim([0 yl2]);box on
     figure(2), plot(sortedfrac,allMsox2(idx),'p','MarkerFaceColor','c','MarkerEdgeColor','k','Markersize',18);     
     ylim([0 yl1]);box on

h = figure(1);
h.CurrentAxes.FontSize = 18;
h.CurrentAxes.LineWidth = 3;
xlabel('Fraction of CFP+(diff) cells in the colony');
ylabel(['Mean ' num2str(param1) ' in other cells']);
title('esi cells Sorted,original experiemnt 60:40');
legend('42 hours of sorting');
legend('42 hours of sorting','Location','Northwest');

h = figure(2);
h.CurrentAxes.FontSize = 18;
h.CurrentAxes.LineWidth = 3;
xlabel('Fraction of CFP+(diff) cells in the colony');
ylabel(['Mean ' num2str(param2) 'in the non-CFP']);
title('esi cells Sorted,original experiemnt 60:40');
legend('42 hours of sorting','Location','Northwest');
% now scatter and colorcode by colony size
custmap = allsz(idx);
custmap(custmap>2500)=2500;
figure(3),scatter(sortedfrac,allMbra(idx),[],allsztrue,'LineWidth',2); colorbar; ylim([0 yl2]);box on
xlabel('Fraction of CFP+(diff) cells in the colony');
ylabel(['Mean ' num2str(param1) ' in the non-CFP']);
h = figure(3);
h.Colormap = jet;
h.CurrentAxes.FontSize = 18;
h.CurrentAxes.LineWidth = 3;
title('esi cells Sorted,original experiemnt 60:40');
[cmin cmax]=caxis;
caxis([cmin 2000])
colorbar
figure(4),scatter(sortedfrac,allMsox2(idx),[],allsztrue,'LineWidth',2); colorbar; ylim([0 yl1]); box on
xlabel('Fraction of CFP+(diff) cells in the colony');
ylabel(['Mean ' num2str(param2) ' in the non-CFP']);
h = figure(4);
h.Colormap = jet;
h.CurrentAxes.FontSize = 18;
h.CurrentAxes.LineWidth = 3;
title('esi cells Sorted,original experiemnt 60:40');
[cmin cmax]=caxis;
caxis([cmin 2000])
colorbar

figure(5),scatter(sortedfrac,allMbraFrac(idx),[],allsztrue,'LineWidth',2); colorbar; ylim([0 1]); box on
xlabel('Fraction of CFP+(diff) cells in the colony');
ylabel(['Frac ' num2str(param1) ' in the non-CFP']);
h = figure(5);
h.Colormap = jet;
h.CurrentAxes.FontSize = 18;
h.CurrentAxes.LineWidth = 3;
title('esi cells Sorted,original experiemnt 60:40');
[cmin cmax]=caxis;
caxis([cmin 2000])
colorbar