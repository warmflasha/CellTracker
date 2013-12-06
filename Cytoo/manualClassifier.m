function [shapes, rotate]=manualClassifier(matfile,resave)

if ~exist('resave','var')
    resave=0;
end

pp=load(matfile,'plate1');
plate1=pp.plate1;
cellthresh = 50;

shapes=[plate1.colonies.shape];
rotate=[plate1.colonies.rotate];

ncells = [plate1.colonies.ncells];

inds2classify = find(ncells > cellthresh);

nc=length(inds2classify);

disp(['There are ' int2str(nc) ' colonies to classify']);

% h=figure;
% set(h,'WindowStyle','docked');
% subplot(2,1,1);
%imshow('~/work/CellTracker/Cytoo/shapes.png');
for kk=1:nc
    ii=inds2classify(kk);
    clf;
    plate1.colonies(ii).plotColonyColorPoints(0);
    axis equal;
    xmin = min(plate1.colonies(ii).data(:,1));
    ymin = min(plate1.colonies(ii).data(:,2));
    xmax = max(plate1.colonies(ii).data(:,1));
    ymax = max(plate1.colonies(ii).data(:,2));

    xdist = (xmax-xmin)/3;
    ydist = (ymax-ymin)/3;
    
    line([xmin xmax],[ymax+10 ymax+10]);
    text((xmin+xmax)/2,ymax+15,[num2str(xdist) ' \mum']);
    
    line([xmax+10 xmax+10],[ymin ymax]);
    text(xmax+15,(ymin+ymax)/2,[num2str(ydist) ' \mum']);
    
    xx=input(['Colony ' int2str(kk) '\nEnter shape number.\nEnter a negative number to rotate the colony 180 degrees\nEnter 0 to skip\n']);
    if xx < 0
        plate1.colonies(ii).rotate = 1;
        plate1.colonies(ii).shape = -xx;
    else
        plate1.colonies(ii).rotate = 0;
        plate1.colonies(ii).shape=xx;
    end
    
    shapes=[plate1.colonies.shape];
    rotate=[plate1.colonies.rotate];
    
    save('tmp.mat','shapes','rotate');
    
end

shapes=[plate1.colonies.shape];
rotate=[plate1.colonies.rotate];

if resave
    save(matfile,'plate1','-append');
end