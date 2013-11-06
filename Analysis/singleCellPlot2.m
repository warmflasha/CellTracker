function [datareturn curseur]= singleCellPlot2(celldata,pictimes,chans,varargin)
%function singleCellPlot(cells,ii,pictimes,paxes,feedings)
%--------------------------
%Function to plot the single cell trajectory for cell ii, data time points
%pictimes, axes of plot paxes. If feedings is including will plot feeding
%lines. Use mksinglecellplots to make many single cell plots.
% frameNb is an optional parameter specifying the frame number of a point
% to highlight BS 23/3/2011

p=inputParser;
p.addRequired('celldata',@isstruct);
p.addRequired('pictimes',@isnumeric);
p.addRequired('chans',@isnumeric);
p.addParamValue('feedings',[],@isstruct);
p.addParamValue('frameNb',-1,@isnumeric);
p.addParamValue('plotspline',1,@isnumeric);
p.addParamValue('PlotStyle','k.-',@ischar);
p.addParamValue('NormToStart',0,@isnumeric);

p.parse(celldata,pictimes,chans,varargin{:});

frameNb=p.Results.frameNb; feedings=p.Results.feedings;
plotspline=p.Results.plotspline; ps=p.Results.PlotStyle;
NormToStart=p.Results.NormToStart;


if frameNb==-1
    highlightOnePoint = 0;
else
    highlightOnePoint = 1;
end

if isempty(feedings)
    feed=0;
else
    fmedianum=[feedings.medianum];
    ftimes=[feedings.time];
    fls={'r','g','b','k','m','c','y','r','g','b','k','m','c','y','r','g','b','k','m','c','y'};
    feed=1;
end

tdata=pictimes(celldata.onframes);

if length(chans)==1 && NormToStart==0
    datatoplot=celldata.fdata(:,chans(1));
elseif length(chans)==1 && NormToStart==1
    datatoplot=celldata.fdata(:,chans(1))/celldata.fdata(1,chans(1));
elseif length(chans)==2
    datatoplot=celldata.fdata(:,chans(1))./celldata.fdata(:,chans(2));
end

plot(tdata,datatoplot,ps); hold on;
datareturn=datatoplot;

if plotspline % BS edit : option to not plot the spline in the case of cells that are not good
    if length(chans)==1 && NormToStart==0
        sdatatoplot=celldata.sdata(:,chans(1));
    elseif length(chans)==1 && NormToStart==1
        sdatatoplot=celldata.sdata(:,chans(1))/celldata.sdata(1,chans(1));
    elseif length(chans)==2
        sdatatoplot=celldata.sdata(:,chans(1))./celldata.sdata(:,chans(2));
    end
    plot(tdata,sdatatoplot,ps(1));
end

% BS edit
if highlightOnePoint
    frameNbIdx = find(celldata.onframes == frameNb);
    curseur = plot(pictimes(celldata.onframes(frameNbIdx)),datatoplot(frameNbIdx),'ko','MarkerSize',12);
else
    curseur=[];
end

%%%% highlight the maxs as defined in lmaxcell. plot only max in nuc to
%%%% cyto ratio
if ~isempty(celldata.lmaxcell)&&~isempty(celldata.lmaxcell{1,4})
    
    for yy = 1:length(celldata.lmaxcell{1,4})
        MaxFrameAbsolute(yy) = celldata.lmaxcell{1,4}(yy).frame;
        jumps(yy) = celldata.lmaxcell{1,4}(yy).jump;
    end
    % MaxFrameAbsolute
    % jumps
    MaxFrameAbsolute = MaxFrameAbsolute(jumps>0);
    MaxFrameRelative = MaxFrameAbsolute - celldata.onframes(1) + 1;
    
    % celldata.data(MaxFrame,6)./celldata.data(MaxFrame,7)
    %plot(pictimes(MaxFrameAbsolute),datatoplot(MaxFrameRelative),'ro','MarkerSize',12);
    
end

% end BS edit

%axis(paxes);
%title(['cell: ' int2str(ii)])
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