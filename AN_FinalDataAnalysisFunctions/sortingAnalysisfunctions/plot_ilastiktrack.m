function [x,y,time,r3,nuc,nuc2]=plot_ilastiktrack(trN,s,pos,flag)

object_id = s.data(:,1);
timestep = s.data(:,2);
lineage_id = s.data(:,4);
track_id1= s.data(:,5);
RegionCenter_0= s.data(:,9);
RegionCenter_1= s.data(:,10);

[r3,~]=find(track_id1==trN);
%check if correspond to actual trace in time
if ~isempty(r3)
time = timestep(r3);
C = {'r','b'};
if flag == 1
figure(1),plot(time,RegionCenter_0(r3),C{1},'LineWidth',3);ylim([0 max(RegionCenter_0(r3))+100]);box on
h=figure(1);
h.CurrentAxes.LineWidth = 3;
h.CurrentAxes.FontSize = 22;
xlabel('time, frames');
ylabel('RegionCenter0 coordinate (ilasik)')
end
y=RegionCenter_1(r3);%
x=RegionCenter_0(r3);%
% plot on top of image time point
direc1 ='/Volumes/TOSHIBAexte/2017-06-29-livesorting_SDConfocalbetaCatcellspluri/2017-07-05-liveSortingMaxProjections';
ff1 = readAndorDirectory(direc1);% nuc
nucmoviefile = getAndorFileName(ff1,ff1.p(pos),2,0,2);  
nreader = bfGetReader(nucmoviefile);
nt = nreader.getSizeT;
ii = time(1)+1;   
    iplane = nreader.getIndex(0,0,ii-1)+1;
    nuc = bfGetPlane(nreader,iplane);  
    iplane2 = nreader.getIndex(0,0,time(end)-1)+1;
    nuc2 = bfGetPlane(nreader,iplane2);  
    if flag == 1
    figure(2), imshow(imadjust(nuc,stretchlim(nuc)),[]);hold on
    figure(2), imshowpair(imadjust(nuc,stretchlim(nuc)),imadjust(nuc2,stretchlim(nuc2)));hold on
    plot(x,y,'cp-','Markersize',5,'LineWidth',3);hold on
    plot(x(1),y(1),'mp-','Markersize',20,'MarkerFaceColor','r');hold on
    text(x(1)+10,y(1)-10,['Start,' num2str(time(1))],'FontSize',20,'Color','y');hold on
    plot(x(end),y(end),'mp-','Markersize',20,'MarkerFaceColor','y');hold on
    text(x(end)+3,y(end)-3,['End,' num2str(time(end))],'FontSize',20,'Color','y');hold on
    end
end
if isempty(r3)
   disp('there is not track with such number') 
end
end