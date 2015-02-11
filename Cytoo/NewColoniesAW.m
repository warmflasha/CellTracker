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
XX=ipdm(pts);
ncells = size(pts,1);
groupids=zeros(ncells,1);
mindist = 80;% 40 for the 10X images
currentgroup=1;
cellsleft = 1:ncells;

while ~isempty(cellsleft)
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

cc=colorcube(20);

figure; hold on;
for ii=1:20:ngroups% plot every 20th image
    inds = groupids == ii;
    plot(pts(inds,1),pts(inds,2),'.','Color',cc(mod(ii,20)+1,:),'MarkerSize',18);
end