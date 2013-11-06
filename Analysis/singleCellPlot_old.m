function singleCellPlot(cells,ii,pictimes,paxes,feedings,frameNb,rat)
%function singleCellPlot(cells,ii,pictimes,paxes,feedings)
%--------------------------
%Function to plot the single cell trajectory for cell ii, data time points
%pictimes, axes of plot paxes. If feedings is including will plot feeding
%lines. Use mksinglecellplots to make many single cell plots.
% frameNb is an optional parameter specifying the frame number of a point
% to highlight BS 23/3/2011

if ~exist('frameNb','var')|| isempty(frameNb)
    highlightOnePoint = 0;
else
    highlightOnePoint = 1;
end

if ~exist('feedings','var') || isempty(feedings)
    feed=0;
else
    fmedianum=[feedings.medianum];
    ftimes=[feedings.time];
    fls={'r','g','b','k','m','c','y'};
    feed=1;
end

if ~exist('rat','var') || isempty(rat)
    rat=0;
end

if rat
    plot(pictimes(cells(ii).onframes),cells(ii).data(:,9)./cells(ii).data(:,10),'g',...
        'LineWidth',2);
    hold on;
    plot(pictimes(cells(ii).onframes),cells(ii).data(:,6)./cells(ii).data(:,7),'g.');
    plot(pictimes(cells(ii).onframes),cells(ii).data(:,8)/cells(ii).data(1,8),'r',...
        'LineWidth',2);
    plot(pictimes(cells(ii).onframes),cells(ii).data(:,5)/cells(ii).data(1,5),'r.');
else
    plot(pictimes(cells(ii).onframes),cells(ii).data(:,9),'g','LineWidth',2);
    hold on;
    plot(pictimes(cells(ii).onframes),cells(ii).data(:,6),'g.');
    plot(pictimes(cells(ii).onframes),cells(ii).data(:,8),'r',...
        'LineWidth',2);
    plot(pictimes(cells(ii).onframes),cells(ii).data(:,5),'r.');
end


% BS edit
if highlightOnePoint
    frameNbIdx = find(cells(ii).onframes == frameNb);
    plot(pictimes(cells(ii).onframes(frameNbIdx)),cells(ii).data(frameNbIdx,6)./cells(ii).data(frameNbIdx,7),'ko','MarkerSize',12)
end
% end BS edit

axis(paxes);
title(['cell: ' int2str(ii)])
if feed==1
    yy=ylim; xx=xlim;
    xlim([xx(1)-0.5 xx(2)]);
    for kk=1:length(ftimes)
        if ftimes(kk) > xx(1)-1 && ftimes(kk) < xx(2)+1
            line([ftimes(kk) ftimes(kk)],yy,'Color',fls{fmedianum(kk)},...
                'LineStyle','--','LineWidth',1);
        end
    end
end
drawnow;
hold off;