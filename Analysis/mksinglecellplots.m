function mksinglecellplots(matfile,plotarray,paxes,rat,maxplots)
% function mksinglecellplots(matfile,plotarray,paxes,maxplot)
%-------------------------------------------------------------
% function to make plots of single cell trajectories
% matfile - output matfile from tracker containing data
% plotarray (optional) -- 2 component vectors [m n].
%           if specified will put many plots in the same figure in an m by
%           n array. default 1 plot/figure
% paxes -- 4 component vector for call axis(paxes) to make axes of plot
% maxplots (optional)-- maximum number of plots to make. default 45.
% plots smoothing spline trajectories as lines with actual data as points
% must run decideifgoodaddspline.m on cell structure first.
% calls singleCellPlot to make each plot

load(matfile,'cells','cells2','pictimes','feedings');

if exist('cells2','var')
    cells=cells2;
end

if ~exist('maxplots','var')
    maxplots=45;
end


if ~exist('rat','var')
    rat=1;
end


if exist('plotarray','var')
    usearray=1;
    nplots=prod(plotarray);
else
    usearray=0;
end

if ~exist('paxes','var') || isempty(paxes)
    paxes=[0 max(pictimes([cells2.onframes])) 0.2 2];
end

if ~exist('feedings','var')
    feedings=[];
    mklegend=0;
else
    mklegend=1;
end

q=1;
for ii=1:length(cells)
    
    if myIsField(cells,'good')
        if isempty(cells(ii).good)
            cells(ii).good=0;
            usecell=0;
        elseif cells(ii).good && q <= maxplots
            usecell=1;
        else
            usecell=0;
        end
    else
        if length(cells(ii).onframes)/length(peaks) > 0.8
            usecell=1;
        else
            usecell=0;
        end
    end
    if usecell
        if usearray
            spn=mod(q,nplots);
            if spn==0
                spn=nplots;
            end
        end
        
        if ~usearray || (usearray && spn==1)
            figure;
        end
        if usearray
            subplot(plotarray(1),plotarray(2),spn);
        end
        singleCellPlot(cells,ii,pictimes,paxes,feedings,[],rat);
        q=q+1;
    end
end