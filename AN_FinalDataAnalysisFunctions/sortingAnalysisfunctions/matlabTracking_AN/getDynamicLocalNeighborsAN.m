% get the centroid coordinatesof the other cell type (non-CFP)
totrack = 100;
direc1 ='C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff';
ifile = ['C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff\SortingGFPS4cellspluri70to30_MIP_f0000_w0001_Simple Segmentation.h5'];%stmp{end-1}(2:end)
tpt_end = 80; % how many timepoints to track cells for, in frames
pos = 1;%1
chan = 1;% 0 - cfp cells; 1- nuc marker of other cell type
paramfile = 'C:\Users\Nastya\Desktop\FromGithub\CellTracker\paramFiles\setUserParamTrackSortingAN_20X.m';
run(paramfile)
global userParam 
[nmask,pluristats] = getdatatotrack(direc1,pos,chan,userParam.arealow,ifile);
% centroids of pluri cells (cell type 1) are in the var pluristats
% tracked data for CFP cells (cell type 2) are in var coordintime
 nucmoviefile1 = getAndorFileName(ff1,ff1.p(pos),[],[],chan);%getAndorFileName(files,pos,time,z,w)
 r1 = bfopen(nucmoviefile1);

imagedir  ='C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff';
%allcellsinimg = cat(1,datatomatch(timepoint).stats.Centroid);
ff1 = readAndorDirectory(imagedir);
 pos = 1;
 chan = 0;
 nucmoviefile = getAndorFileName(ff1,ff1.p(pos),[],[],chan);%getAndorFileName(files,pos,time,z,w)
% nreader = bfGetReader(nucmoviefile);
% nt = nreader.getSizeT;
 r = bfopen(nucmoviefile);
 ifile = ['C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff\SortingGFPS4cellspluri70to30_MIP_f0000_w0000_Simple Segmentation.h5'];%stmp{end-1}(2:end)
 [nmask2,cfpstats] = getdatatotrack(direc1,pos,chan,userParam.arealow,ifile);
 
%%
local_sz = 70;
jj = 50;% time point
allcells_type1 = round(cat(1,pluristats(jj).stats.Centroid));% centrois of all pluri cells at tp jj
allcells_type2 = round(cat(1,cfpstats(jj).stats.Centroid));% centrois of all pluri cells at tp jj

curr_track = coordintime(totrack).dat(jj,:);% coord of cell of other type, for which the neighborhood is quantified
rawimg1 = (r1{1}{jj});% pluri cells
rawimg = (r{1}{jj});% cell type 2 (cfp cells)
total_img = max(rawimg1,rawimg);
figure(jj),imshow(total_img,[500 1500]);hold on % show the raw image in the CFP channel
%figure(jj),imshowpair(rawimg1,rawimg);hold on % show the raw image in the CFP channel

plot(allcells_type2(:,1),allcells_type2(:,2),'pb','MarkerFaceColor','b','Markersize',5);
figure(jj),plot(coordintime(totrack).dat(jj,1),coordintime(totrack).dat(jj,2),'kp','MarkerFaceColor','y','MarkerSize',11,'LineWidth',1);hold on%colormap(randcolor,:)
plot(allcells_type1(:,1),allcells_type1(:,2),'pr','MarkerFaceColor','r','Markersize',5);hold on
%at each time point find how many cells of each type are surrounding
% the given cell ( within the several cell radius)
allcells = cat(1,allcells_type1,allcells_type2); % all cells, including the coord of a current cell 

local_neighbors = ipdm(coordintime(totrack).dat(jj,1:2),allcells,'Result','Structure','Subset','Maximum','Limit',local_sz);% get all the cells, closer than local_sz
% need to remove the closest cell from the list (since it's the tracked
% cell itself):
[~,c]=find(local_neighbors.distance==min(local_neighbors.distance));
local_neighbors.columnindex(c)=[];
% local_neighbors.columnindex - cells within the rad of local_sz
% 
figure(jj+1),imshow(total_img,[500 1500]);hold on % show the raw image in the CFP channel
figure(jj+1),plot(coordintime(totrack).dat(jj,1),coordintime(totrack).dat(jj,2),'kp','MarkerFaceColor','y','MarkerSize',11,'LineWidth',1);hold on%colormap(randcolor,:)
figure(jj+1),plot(allcells(local_neighbors.columnindex',1),allcells(local_neighbors.columnindex',2),'*b');

% TODO: now need to see which of these are cfp and wich are pluri
% then see if there is a correlaion between celltype1 motion (velocity,
% etc) and the number of neighbors of specific type

totest = allcells(local_neighbors.columnindex',:);
nearest = size(totest,1);
counter = 0;
for h=1:size(totest,1)
    % if one of the found local neighborhood cells are in the set of
    % celltype2, the nearest neighbor to it will be at zero distance
    % counting how many of those, gives the number of neighbors of cell
    % type2, the rest (nearest-counter), is the other cell type
    tmp = ipdm(totest(h,:),allcells_type2,'Result','Structure','Subset','NearestNeighbor');%    
    if tmp.distance == 0
        counter = counter+1;
    end
end
sametype_neighbor = counter;
othertype_neighbor = (nearest-counter);
fraction_same = sametype_neighbor/nearest;






