function drawFeedingLines(feedings,paxes)

if exist('paxes','var')
    tmp=axes(paxes);
end



fmedianum=[feedings.medianum];
ftimes=[feedings.time];
fls={'r','g','b','k','m','c','y','r','g','b','k','m','c','y','r','g','b','k','m','c','y'};

yy=ylim; xx=xlim;
%xlim([xx(1)-0.5 xx(2)]);
for kk=1:length(ftimes)
    %if ftimes(kk) > xx(1)-1 && ftimes(kk) < xx(2)+1
        line([ftimes(kk) ftimes(kk)],yy,'Color',fls{fmedianum(kk)},...
            'LineStyle','--','LineWidth',1);
    %end
end

drawnow;
hold off;