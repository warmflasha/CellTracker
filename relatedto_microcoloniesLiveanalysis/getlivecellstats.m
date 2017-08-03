%% extracs stats from the once cell traces
%load('registeredDAPI.mat','tracesbybin','cdx2val','tracesbybin2','binSZ','datatogether');
load('registeredDAPInewTraces.mat','tracesbybin','tracesbybin2','binmean','binmean2','err','err2','binSZ','datatogether','cdx2val');

base = [];
meanaft = [];
jump = [];
tracesd = [];
signlast = [];
fr_stim = 16;
tresp = 6;
last = [90:100];

for j =1:size(binmean,2)% loop over the bins;         
for k=1:size(tracesbybin{j},2)
    
    base(k,j) = mean(nonzeros((tracesbybin{j}(1:fr_stim,k))));
    meanaft(k,j) = mean(nonzeros((tracesbybin{j}(fr_stim:end,k))));
    jump(k,j) = abs(tracesbybin{j}(fr_stim+tresp,k)-tracesbybin{j}(fr_stim,k));
    tracesd(k,j) = std(nonzeros((tracesbybin{j}(fr_stim:end,k))));
   % signlast(k,j)=mean(nonzeros((tracesbybin{j}(last(1):last(2),k))));
end
end
%% plot stats
%load('registeredDAPI.mat','base','cdx2val','meanaft','jump','tracesd','signlast');
% finsign, cdx2val
load('registeredDAPInewTraces','finsign','cdx2val','binSZ');
bins = 2;
C = {'c','r','r'};
sym = {'.','*','d','s','o'};
a = 400;
yl = 2;
for k=1:bins
        s =  size(nonzeros(finsign{k}),1);
        v = nonzeros(cdx2val{k}');
        
        figure(1),scatter(nonzeros(finsign{k}(:)),v(1:s),a,C{k},sym{2});hold on
        
        xlim([0 yl]);
        ylim([0 yl]);
    
end
xlabel('signaling');%Base level of signaling    mean after
ylabel('Cdx2');
box on
h = figure(1);
h.Children.FontSize = 18;
legend(['cdx2 <' num2str(binSZ)],['cdx2 >' num2str(binSZ)]);
title('<signaling> in matched 1cell uCol over last 15 tpt');
yy = (0:0.5:yl);
xx = ones(size(yy));
figure(1), hold on
plot(xx,yy,'k-','Linewidth',1);
xx = (0:0.5:yl);
yy = ones(size(yy));
figure(1), hold on
plot(xx,yy,'k-','Linewidth',1);




