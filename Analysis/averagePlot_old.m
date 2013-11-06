function avgreturn=averagePlot(cells,plotcols,pictimes,feedings,ps,mkhandle,mklegend)
%function avgreturn=averagePlot(cells,plotcols,pictimes,feedings,ps,mkhandle)
%---------------------------
%Function to make average plot from cells array. see help to mkAveragePlot
%which is a wrapper to load matfile set options and call this function.

fls={'r','g','b','k','m','c','y'};

if ~exist('mklegend','var')
    mklegend=1;
end

if mklegend && mkhandle
    disp('Warning mklegend and mkhandle both set. Setting mkhandle=0')
    mkhandle=0;
end
nframes=length(pictimes);
framestoplot=1:nframes;
counter=zeros(nframes,1); avgfluor = zeros(nframes,1);
mintrajlength=3;

for ii=1:(length(cells)-1)
    of=cells(ii).onframes;
    framestouse=ismember(of,framestoplot) & cells(ii).data(:,7)'>0;
    if sum(framestouse) >= mintrajlength
        of=of(framestouse);
        len=length(of);
        counter(of)=counter(of)+ones(len,1);
        if length(plotcols)==2
            if plotcols(2)~=plotcols(1)
                avgfluor(of)=avgfluor(of)+cells(ii).data(framestouse,plotcols(1))...
                    ./cells(ii).data(framestouse,plotcols(2));
            else
                firsti=find(framestouse,1);
                avgfluor(of)=avgfluor(of)+cells(ii).data(framestouse,plotcols(1))...
                    /cells(ii).data(firsti,plotcols(1));
            end
        elseif length(plotcols)==1
            avgfluor(of)=avgfluor(of)+cells(ii).data(framestouse,plotcols);
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

if exist('feedings','var') && ~isempty(feedings)
    ftimes=[feedings.time];
    fmedianum=[feedings.medianum];
    yy=ylim; xx=xlim;
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
if mklegend && ~isempty(feedings)
legend(leg,'FontSize',14);
end
