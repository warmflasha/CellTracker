function cells=findresponse(cells,feedings,pictimes)

fmedianum=[feedings.medianum];
ftimes=[feedings.time];

%find the media type changing
fdiff=diff(fmedianum);
chtimes=ftimes(find(fdiff)+1);

%for pulses, only include "on"
difftimes=diff(chtimes);
xx=find(difftimes<3);
chtimes(xx+1)=[];

for ii=1:length(cells)
    if cells(ii).good
        ncr=cells(ii).data(:,9)./cells(ii).data(:,10);
        [mx lmx mn lmn]=extrema(ncr);
        %for each pulse, find response
        for jj=1:length(chtimes)
            timeafterpulse=pictimes(cells(ii).onframes(lmx))-chtimes(jj);
            [tsort ind]=sort(timeafterpulse);
            rind=ind(find(tsort>0,1));
            if isempty(rind) || timeafterpulse(rind) > 3
                rh(jj)=0;
                rt(jj)=0;
            else
                rh(jj)=mx(rind);
                rt(jj)=timeafterpulse(rind);
            end
        end
        cells(ii).response=rh;
        cells(ii).responsetimes=rt;
        cells(ii).maxes=mx;
        cells(ii).maxinds=lmx;
        cells(ii).mins=mn;
        cells(ii).mininds=lmn;
    end
end

