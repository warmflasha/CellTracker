%instead of PeaksToColonies
%alphavolume does not work well if the colonies are small (2-3 cells)

%filename = ['Final outall files' filesep 'outall(' nms{xx} ').mat'];
%ipds, property "result': result = 'Structure' --> A list of all computed distances,
%defined as a structure. This structure
%will have fields named 'rowindex',
%'columnindex', and 'distance'.If only data1 is provided, then the distance matrix
%is computed between all pairs of rows of data1.
%ipdm: Inter-Point Distance Matrix.
%d = ipdm(data1,data2);d(i,j) represents the distance between point i
%(from data1) and point j (from data2).
%d = ipdm(data1,data2,prop,value)

%%get the data
%load outall(500).mat;
%[~,N1]=size(peaks);
%data=peaks{65}(:,1:2);
%% sort into groups -- output is vector groupid
function [groupids]= NewColoniesAW(pts)

global userParam;
%userParam.colonygrouping = 120;

XX=ipdm(pts);
% XX1 = pdist(pts);   % pdist with squareform is the same as the ipdm ( but only part of the statistical toolbox)
% XX = squareform(XX1);
ncells = size(pts,1);
groupids=zeros(ncells,1);
mindist = userParam.colonygrouping;% 40 for the 10X images % 80 for 20X images % ~ 120 for 60X images % need to put in the paramfile!!!!
currentgroup=1;
cellsleft = 1:ncells;

while ~isempty(cellsleft) %&& ~isempty(XX) %% AN
    currentcell=cellsleft(1);
    groupids(currentcell)=currentgroup;
    cellsleft=setdiff(cellsleft,currentcell);
    inds=find(XX(:,currentcell) < mindist & XX(:,currentcell) > 0);
    groupids(inds)=currentgroup;
    cellsleft=setdiff(cellsleft,inds);
    indscurrentgroup=find(groupids==currentgroup);
    
    addtocurrent=[];
    for ii=1:length(indscurrentgroup)
        closetocell=find(XX(:,indscurrentgroup(ii))<mindist & XX(:,indscurrentgroup(ii))>0);
        addtocurrent=[addtocurrent; intersect(closetocell,cellsleft)];
    end
    addtocurrent=unique(addtocurrent);
    while ~isempty(addtocurrent)
        groupids(addtocurrent)=currentgroup;
        cellsleft=setdiff(cellsleft,addtocurrent);
        indscurrentgroup=find(groupids==currentgroup);
        addtocurrent=[];
        for ii=1:length(indscurrentgroup)
            closetocell=find(XX(:,indscurrentgroup(ii))<mindist & XX(:,indscurrentgroup(ii))>0);
            addtocurrent=[addtocurrent; intersect(closetocell,cellsleft)];
        end
        addtocurrent=unique(addtocurrent);
    end
    currentgroup = currentgroup+1;
    cellsleft = find(groupids==0);
end

%plot with group coding by group

ngroups = max(groupids);

cc=colorcube(10);

% figure; hold on;
% for ii=1:ngroups% plot 
%     inds = groupids == ii;
%     plot(pts(inds,1),pts(inds,2),'*','Color',cc(mod(ii,ngroups)+1,:),'MarkerSize',18);%cc(mod(ii,20)+1,:)
% end
end