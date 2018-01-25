% get the centroid coordinatesof the other cell type (non-CFP)
function [samecell_neighbors,othercell_neighbors,same_neighbor_abs,other_neighbor_abs,curr_cell_speed,curr_cell_rad]= getDynamicLocalNeighborsAN(trackID,paramfile,coordintime,matlabtracking,delta_t,pluristats,diffstats,img_pluri,img_diff,toplot)
run(paramfile)
global userParam

for totrack =trackID 
tpts = size(coordintime(totrack).dat,1);%size(cfpstats,2)
time = 3;
if matlabtracking == 1
    time = 5;
    tpts = size(coordintime(totrack).dat,1);
end
colormap = prism;
v_2 = struct; % totla velocity at each time point
v = struct; %
othertype_neighbor = struct;
sametype_neighbor = struct;
fraction_same = struct;
fraction_other = struct;
direction = struct;
displ = struct;
for jj = 1: (tpts-1)% time points    (size(cfpstats,2)-1)
allcells_type1 = round(cat(1,pluristats(jj).stats.Centroid));% centrois of all pluri cells at tp jj
allcells_type2 = round(cat(1,diffstats(jj).stats.Centroid));% centrois of all pluri cells at tp jj
curr_track = coordintime(totrack).dat(jj,:);% coord of cell of other type, for which the neighborhood is quantified
rawimg1 = (img_pluri{1}{jj});% untracked
rawimg = (img_diff{1}{jj});% tracked
total_img = max(rawimg1,rawimg);
%figure(jj),imshow(total_img,[500 1500]);hold on % show the raw image in the CFP channel
%figure(jj),imshowpair(rawimg1,rawimg);hold on % show the raw image in the CFP channel
%plot(allcells_type2(:,1),allcells_type2(:,2),'pb','MarkerFaceColor','b','Markersize',5);
%figure(jj),plot(coordintime(totrack).dat(jj,1),coordintime(totrack).dat(jj,2),'kp','MarkerFaceColor','y','MarkerSize',11,'LineWidth',1);hold on%colormap(randcolor,:)
%plot(allcells_type1(:,1),allcells_type1(:,2),'pr','MarkerFaceColor','r','Markersize',5);hold on

%at each time point find how many cells of each type are surrounding
% the given cell ( within the several cell radius)
allcells = cat(1,allcells_type1,allcells_type2); % all cells, including the coord of a current cell 
local_neighbors = ipdm(coordintime(totrack).dat(jj,1:2),allcells,'Result','Structure','Subset','Maximum','Limit',userParam.local_sz);% get all the cells, closer than local_sz
% v = power((vx^2+vy^2),0.5); vx = dx/dt;
tp1 =jj;
tp2 = jj+1;
% disp([tp1 tp2]);
dt = (tp2-tp1)*delta_t/60;
dx = (coordintime(totrack).dat(tp2,1)-coordintime(totrack).dat(tp1,1))*userParam.pxtomicron;
dy = (coordintime(totrack).dat(tp2,2)-coordintime(totrack).dat(tp1,2))*userParam.pxtomicron;
vx_2 = power(dx/dt,2);
vy_2 = power(dy/dt,2);
v_2(jj).total = power((vx_2+vy_2),0.5); 
v(jj).vx = dx/dt;
v(jj).vy = dy/dt;
displ(jj).dat = power(dx*dx+dy*dy,0.5);
% TODO: calculate the angle between the velocity vector of the tracked cell
% and the velocity vector of the cell of the opposite type (one from the
% neighborhood). Or do the angle btw the v(cfp cell) and the refernce direction +Ox, for
% example
if (v(jj).vy>=0) && (v(jj).vx>=0)
direction(jj).rad = atan(abs(v(jj).vy)/abs(v(jj).vx));% returns angle in radians  
direction(jj).theta = (direction(jj).rad)*180/3.14; % in degrees
end
%----------
if (v(jj).vy>=0) && (v(jj).vx<=0)
direction(jj).rad = 3.14-atan(abs(v(jj).vy)/abs(v(jj).vx));% returns angle in radians      
direction(jj).theta = 180-((direction(jj).rad)*180/3.14); % in degrees
end
if (v(jj).vy<=0) && (v(jj).vx>=0)
direction(jj).rad = (3.14*270)/180+atan(abs(v(jj).vy)/abs(v(jj).vx));% returns angle in radians
direction(jj).theta = 270+((direction(jj).rad)*180/3.14); % in degrees
end
if (v(jj).vy<=0) && (v(jj).vx<=0)
direction(jj).rad = 3.14+atan(abs(v(jj).vy)/abs(v(jj).vx));% returns angle in radians   
direction(jj).theta = 180+((direction(jj).rad)*180/3.14); % in degrees
end
%----------
% need to remove the closest cell from the list (since it's the tracked
% cell itself):
[~,c]=find(local_neighbors.distance==min(local_neighbors.distance));
local_neighbors.columnindex(c)=[];
% local_neighbors.columnindex - cells within the rad of local_sz
if (jj == 1) && (toplot == 1)%last tp: (tpts-1)
figure(jj),imshow(total_img,[500 1500]);hold on % show the raw image in the CFP channel
figure(jj),imshowpair(rawimg1,rawimg);hold on % show the raw image in the CFP channel
figure(jj),plot(coordintime(totrack).dat(jj,1),coordintime(totrack).dat(jj,2),'kp','MarkerFaceColor','y','MarkerSize',11,'LineWidth',1);hold on%colormap(randcolor,:)
figure(jj),plot(allcells(local_neighbors.columnindex',1),allcells(local_neighbors.columnindex',2),'*b');hold on
title(['At ' num2str(jj*delta_t/60) 'hrs; Track N# ' num2str(totrack) ]);
end
% now find which of these neighbors are cfp and wich are pluri
% then see if there is a correlaion between celltype1 motion (velocity of tracked cell,
% etc) and the number of neighbors of specific type

totest = allcells(local_neighbors.columnindex',:);
nearest = size(totest,1);% all the cells within the local_sz pixels of the tracked cell
counter = 0;
for h=1:size(totest,1)
    % if one of the found local neighborhood cells are in the set of
    % celltype2, the nearest neighbor to it will be at zero distance (the cell is closest to itself);
    % counting how many of those, gives the number of neighbors of cell
    % type2, the rest (nearest-counter) is the other cell type
    tmp = ipdm(totest(h,:),allcells_type2,'Result','Structure','Subset','NearestNeighbor');%    
    if tmp.distance == 0
        counter = counter+1;        
    end
end
sametype_neighbor(jj).same = counter;
othertype_neighbor(jj).other = (nearest-counter);
fraction_same(jj).frac = counter/(nearest);
fraction_same(jj).abs = counter;
fraction_other(jj).frac = (nearest-counter)/(nearest);
fraction_other(jj).abs=(nearest-counter);
end
%close all
curr_cell_displ = cat(1,displ.dat);
curr_cell_speed = cat(1,v_2.total);
curr_cell_vx = cat(1,v.vx);
curr_cell_vy= cat(1,v.vy);
curr_cell_theta= cat(1,direction.theta);
curr_cell_rad= cat(1,direction.rad);
curr_cell_neighborhood = cat(1,fraction_same.frac);%fraction_same.frac   fraction_other.frac  
curr_cell_neighborhood2 = cat(1,fraction_other.frac);% 
same_neighbor_abs = cat(1,fraction_same.abs);
other_neighbor_abs = cat(1,fraction_other.abs);

% figure(4),scatter((coordintime(totrack).dat(1:end-1,time).*delta_t)/60,curr_cell_speed,[],curr_cell_neighborhood,'filled','Marker','p');box on;title('Color: Fraction of neighbors of the same cell type');ylabel('cell speed, um/hr');xlabel('time, hr');hold on;colorbar
% h4 = figure(4);h4.Colormap = jet;caxis([0 1]);
if (toplot == 1)
figure(2),polarscatter(curr_cell_rad,curr_cell_speed,coordintime(totrack).dat(1:end-1,time),curr_cell_neighborhood,'filled','MarkerEdgeColor','k');hold on%coordintime(totrack).dat(1:end-1,time)
figure(3),plot(coordintime(totrack).dat(1:end-1,time),curr_cell_neighborhood,'-kp','MarkerFaceColor',colormap(randi(size(colormap,1)),:),'MarkerSize',10);hold on
% figure(3),scatter(curr_cell_vy,curr_cell_neighborhood);hold on
 figure(5),scatter(curr_cell_displ,curr_cell_neighborhood2,[],coordintime(totrack).dat(1:end-1,time),'filled','Marker','p');box on;title('Color:Time, frames');ylabel('Fraction of neighbors of the other cell type ');xlabel('Cell displacement,um');hold on;colorbar
h5 = figure(5);h5.Colormap = jet;ylim([0 1]);
cc = corrcoef(curr_cell_displ,curr_cell_neighborhood2);
cc = cc(1,2);
text(curr_cell_displ(end-1),0.9,['Correlation coefficient ' num2str(cc)]);
h = figure(2);
%ylim([0 1.1]); xlim([0 max(curr_cell_speed)]);%max(curr_cell_velocity)
box on
str1 = "Color: Fraction of same type neighbors within " + num2str(round(userParam.local_sz*userParam.pxtomicron))+"um neighborhood";
titlestr = "Velocity of CFPcell wrt +X direction, r(um/hr) theta(degrees)" + "\n" + str1 + " \n"+"Label size increases with frame number";
titlestr = compose(titlestr);
title(titlestr);
h.Colormap = jet;
caxis([0 1]);
colorbar
h1 = figure(3);
ylim([0 1.1]);%xlim([0 max(curr_cell_velocity)]);
box on
xlabel('Time, hours');
ylabel('Fraction of neighbors of the same cell type')
title(['Tracked CFP cell; Neighborhood size ' num2str(round(userParam.local_sz*userParam.pxtomicron)) 'um; Track N# ' num2str(totrack)]);
h1.Colormap = jet;
X = coordintime(totrack).dat(end,time);
h1.CurrentAxes.XTick = (1:7:X);
h1.CurrentAxes.XTickLabel = (1:7:X)*delta_t/60;
end
end
samecell_neighbors=curr_cell_neighborhood;
othercell_neighbors=curr_cell_neighborhood2;


end
