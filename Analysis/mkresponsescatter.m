function mkresponsescatter(matfile,pulsenums)
%function mkresponsescatter(matfile,pulsenums)
%------------------------------------
%function to make a scatterplot of response magnitudes 
%in single cells.
%matfile -- matfile with the data
%           note: need to have run  decideifgoodaddsplines.m and
%           findresponse.m to generate the cells2 structure in the matfile.
%pulsenums -- optional two component vector giving the numbers of the
%               pulses to be plotted. default pulsenums=[1 2].

if ~exist('pulsenums','var')
    pulsenums=[1 2];
end

load(matfile,'cells2','feedings');

fmedianum=[feedings.medianum];
ftimes=[feedings.time];

%find the media type changing
fdiff=diff(fmedianum);
chtimes=ftimes(find(fdiff)+1);

%for pulses, only include "on"
difftimes=diff(chtimes);
xx=find(difftimes<3);
chtimes(xx+1)=[];

nchange=length(chtimes);

resp=[cells2.response];
for ii=1:nchange
respm(:,ii)=resp(ii:nchange:end);
end

mn=min(resp);mx=max(resp);
xx=mn:0.01:mx;
plot(respm(:,pulsenums(1)),respm(:,pulsenums(2)),'r.');
hold on;
plot(xx,xx,'k-','LineWidth',2);
axis([0 2 0 2]);
hold off;