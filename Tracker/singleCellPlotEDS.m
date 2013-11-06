function curseur = singleCellPlotEDS(cells,ii,pictimes,paxis,feedings,frameNb)
%
%   function singleCellPlotEDS(cells,ii,pictimes,paxis,feedings)
%
% Function to plot the nuc-marker and smad nuc/cyto ratio for cell ii, vs time
%   pictimes    physical times for each frame, (x coord of plot)
%   paxis       [xmin,xmax, ymin,ymax] or [] to use default
%   feedings    times of feedings for graph or []
%   frameNB     a single time to mark, or []
%
% will also plot the local max of nuc/cyto if cells.lmaxcell{4} supplied

% max value of fdata(2)/fdata(3) ie nuc/cyto ratio, allowed in plots,
% eliminates Inf when fluor_cyto==0
maxf23 = 2;

% if local max of nuc/cyto plotted, restrict to jumps > this amoung
min_jump = 0.;

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
    fls={'r','g','b','k','m','c','y','r','g','b','k','m','c','y','r','g','b','k','m','c','y'};
    feed=1;
end

% plot raw data
times = pictimes(cells(ii).onframes);
fdata23 = cells(ii).fdata(:,2)./cells(ii).fdata(:,3); % used to plot max below
fdata23(fdata23>maxf23) = maxf23;
plot(times, fdata23,'g.');
hold on;
scaled_fnuc = cells(ii).fdata(:,1)/cells(ii).fdata(1,1);  % save for setting axis
plot(times, scaled_fnuc,'r.');

if cells(ii).good  % plot splines for good cells
    plot(times, cells(ii).sdata(:,2)./cells(ii).sdata(:,3),'g',...
        'LineWidth',1);
    plot(times, cells(ii).sdata(:,1)/cells(ii).fdata(1,1),'r',...
        'LineWidth',1);
end

curseur = [];
if highlightOnePoint
    frameNbIdx = find(cells(ii).onframes == frameNb);
    curseur = plot(pictimes(cells(ii).onframes(frameNbIdx)),cells(ii).fdata(frameNbIdx,2)./cells(ii).fdata(frameNbIdx,3),'ko','MarkerSize',12);
end

%%%% highlight the maxs as defined in lmaxcell. plot only max in nuc to
%%%% cyto ratio
if ~isempty(cells(ii).lmaxcell)&&~isempty(cells(ii).lmaxcell{4}) 
    for yy = 1:length(cells(ii).lmaxcell{4})
        MaxFrameAbsolute(yy) = cells(ii).lmaxcell{4}(yy).frame;
        jumps(yy) = cells(ii).lmaxcell{4}(yy).jump; 
    end
    MaxFrameAbsolute = MaxFrameAbsolute(jumps>min_jump);
    MaxFrameRelative = MaxFrameAbsolute - cells(ii).onframes(1) + 1;
    plot(pictimes(MaxFrameAbsolute), fdata23(MaxFrameRelative), 'ro','MarkerSize',12);
end

if ~isempty(paxis)
    axis(paxis);
else
    tmin = floor( min(times));
    tmax = max(times);
    fmax = max(scaled_fnuc);
    fmax = max(fmax, maxf23);
    axis([tmin,tmax, 0,fmax]);
end

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