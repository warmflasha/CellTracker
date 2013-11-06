function [avgreturn,curseur]=averagePlot2(cells,pictimes,plotcols,varargin)
%function avgreturn=averagePlot(cells,plotcols,pictimes,feedings,ps,mkhandle)
%---------------------------
%Function to make average plot from cells array. see help to mkAveragePlot
%which is a wrapper to load matfile set options and call this function.

p=inputParser;
p.addRequired('cells',@isstruct);
p.addRequired('pictimes',@isnumeric);
p.addRequired('plotcols',@isnumeric);
p.addParamValue('feedings',[],@isstruct);
p.addParamValue('PlotStyle','k.-',@ischar);
p.addParamValue('mkhandle',1,@isnumeric);
p.addParamValue('mklegend',0,@isnumeric);
p.addParamValue('frameNb',-1,@isnumeric);

p.parse(cells,pictimes,plotcols,varargin{:});

frameNb=p.Results.frameNb; feedings=p.Results.feedings;
ps=p.Results.PlotStyle; mkhandle=p.Results.mkhandle;
mklegend=p.Results.mklegend;

fls={'r','g','b','k','m','c','y','r','g','b','k','m','c','y','r','g','b','k','m','c','y'};
if frameNb < 1
   highlightOnePoint = 0;
else
  highlightOnePoint = 1;  
end

nframes=length(pictimes);
framestoplot=1:nframes;
counter=zeros(nframes,1); avgfluor = zeros(nframes,1);
mintrajlength=3;

for ii=1:(length(cells)-1)
    of=cells(ii).onframes;
    framestouse=ismember(of,framestoplot) & cells(ii).fdata(:,3)'>0;
    if sum(framestouse) >= mintrajlength
        of=of(framestouse);
        len=length(of);
        counter(of)=counter(of)+ones(len,1);
        if length(plotcols)==2
            if plotcols(2)~=plotcols(1)
                avgfluor(of)=avgfluor(of)+cells(ii).fdata(framestouse,plotcols(1))...
                    ./cells(ii).fdata(framestouse,plotcols(2));
            else
                firsti=find(framestouse,1);
                avgfluor(of)=avgfluor(of)+cells(ii).fdata(framestouse,plotcols(1))...
                    /cells(ii).fdata(firsti,plotcols(1));
            end
        elseif length(plotcols)==1
            avgfluor(of)=avgfluor(of)+cells(ii).fdata(framestouse,plotcols);
        else
            error('Plotcols must be a vector of length 1 or 2');
            
        end
    end
end
avgreturn=avgfluor(framestoplot)./counter(framestoplot);
if ~exist('mkhandle','var') || mkhandle
    plot(pictimes,avgreturn,ps,'LineWidth',2,'MarkerSize',16);
else
    plot(pictimes,avgreturn,ps,'LineWidth',2,'MarkerSize',16,'HandleVisibility','off');
end
hold on

if exist('feedings','var') && ~isempty(feedings)
    ftimes=[feedings.time];
    fmedianum=[feedings.medianum];
    yy=ylim; xx=xlim;% 
%      yy=[0.6 1.3]; xx=xlim;   
    xlim([xx(1)-0.5 xx(2)]);
    used=zeros(length(fls),1);
    q=1;
    for ii=1:length(ftimes)
        if ftimes(ii) > xx(1)-1 && ftimes(ii) < xx(2)+1
            if ~used(fmedianum(ii))
                used(fmedianum(ii))=1;
                line([ftimes(ii) ftimes(ii)],yy,'Color',fls{fmedianum(ii)},...
                    'LineStyle','--','LineWidth',1.5);
                leg{q}=feedings(ii).medianame;
                q=q+1;
            else
                line([ftimes(ii) ftimes(ii)],yy,'Color',fls{fmedianum(ii)},...
                    'LineStyle','--','LineWidth',1.5,'HandleVisibility','off');
            end
        end
    end
end
set(gca,'YLim',[(floor(min(avgreturn)*10))/10 (ceil(max(avgreturn)*10))/10])

if exist('leg','var') && mklegend 
legend(leg,'FontSize',10);
end

if highlightOnePoint
frameNbIdx = find(cells(ii).onframes == frameNb);
curseur = plot(pictimes(frameNb),avgreturn(frameNb),'ko','MarkerSize',12);
end