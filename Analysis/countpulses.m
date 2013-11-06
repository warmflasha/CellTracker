function [npulses pulseheights pulsetimes totalcells pulseframes]=countpulses(matfile)

ftocheck=4;
minpulse=0.05;

load(matfile,'cells','peaks','pictimes');
cells2=cells;
ncells=length(cells2);

ps={'g.','r.','b.','m.','y.','k.','c.'};

pulseheights=cell(ncells,1);
pulsetimes=cell(ncells,1);
tooclosetoend=0; notbigenough=0;
npulses=zeros(ncells,1); %totalcells=[length(peaks{1}) length(peaks{end})];
totalcells=0;
for jj=1:length(cells2)
    
    if length(cells2(jj).onframes) > 10 && isfield(cells2,'good') 
        totalcells=totalcells+1;
        smoothdat=cells2(jj).sdata(:,2)./cells2(jj).sdata(:,3);
        rawdat=cells2(jj).fdata(:,2)./cells2(jj).fdata(:,3);
        if any(isnan(rawdat) | isinf(rawdat))
            continue;
        end
        nframes=length(rawdat);
        
        [xmax imax xmin imin]=extrema(smoothdat);
        
%         plot(smoothdat,'r-')
%         hold on;
%         plot(rawdat,'rx--');
%         drawnow;
        q=1;
        for ii=1:length(xmax)
            ind=imax(ii); %index of maximum
            imin1=imin-ind;
            indb=max(imin1(imin1<0));
            indf=min(imin1(imin1>0));
            
            if isempty(indb)
                ff=1;
            else
                ff=ind+indb;
            end
            if isempty(indf)
                lf=nframes;
            else
                lf=ind+indf;
            end
            
            if sum(isnan(rawdat(ff:lf))) > 0
                continue;
            end
            
            [rmax, rimax]=max(rawdat(ff:lf));
            [rmin1 rimin1]=min(rawdat(ff:ind));
            [rmin2 rimin2]=min(rawdat(ind:lf));
            
            rimax=ff+rimax-1;
            rimin1=ff+rimin1-1;
            rimin2=ind+rimin2-1;
            
            s1=(rawdat(ff:rimax)-rmin1)/(rmax-rmin1);
            ffr=ff+find(s1<0.3,1,'last')-1;
            
            s2=(rawdat(rimax:lf)-rmin2)/(rmax-rmin2);
            lfr=rimax+find(s2<0.3,1,'first')-1;
            
%             plot(ffr:lfr,smoothdat(ffr:lfr),ps{ii});
%             drawnow;
            diff1=smoothdat(imax(ii))-smoothdat(ff);
            diff2=smoothdat(imax(ii))-smoothdat(lf);
            if diff1 > minpulse && diff2 > minpulse
                %plot(imax(ii),xmax(ii),'gx','MarkerSize',10);
                npulses(jj)=npulses(jj)+1;
                %pheight=max(rawdat(ff:lf))-min(rawdat(ff:lf));
                pheight=rmax-(rmin1+rmin2)/2;
%                 [~, tstart]=min(rawdat(ff:(imax(ii)-1)));
%                 tstart=-ftocheck+tstart;
%                 [~, tfinish]=min(rawdat((imax(ii)+1):lf));
%                 tfinish=ftocheck+tfinish;
                ptime=lfr-ffr;
                midpulse=(lfr+ffr)/2;
                if q==1
                    pulseheights{jj}=pheight;
                    pulsetimes{jj}=ptime;
                    pulseframes{jj}=midpulse;
                    q=q+1;
                else
                    pulseheights{jj}=[pulseheights{jj} pheight];
                    pulsetimes{jj}=[pulsetimes{jj} ptime];
                    pulseframes{jj}=[pulseframes{jj} midpulse];
                end
            else
                notbigenough=notbigenough+1;
            end
            
        end
        %drawnow;
        %input('press enter');
        %hold off;
    end
    
end
end