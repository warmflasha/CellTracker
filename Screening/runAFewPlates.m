platedirs={'Plate7','Plate8','Plate9'};
parfor ii=1:3
    run384Rock(platedirs{ii},[platedirs{ii} '.mat'],'setUserParamRockHiThruSmad2');
end
%%
fid=fopen('CherryPickOut.txt','w');

for jj=1:384
for ii=7:11
    dd=pp(ii).outdatall{jj};
    mm=meannonan(dd(:,6)./dd(:,7));
    fprintf(fid,'%f\t',mm);
end
fprintf(fid,'\n');
end
%%
%fid=fopen('384wellplatelistWData.txt','r');
%rawdat=csvread('384wellplatelistWData.csv');
fid=fopen('test.txt','r');
rawdat=textscan(fid,'%s\t%s\t%d\t%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t');
oldz=[rawdat{5} rawdat{6} rawdat{7} rawdat{8}];
newdat=[rawdat{9} rawdat{10} rawdat{11} rawdat{12} rawdat{13}];
emptyWells=strcmp(rawdat{2},'Empty');
emptyWells = emptyWells & newdat(:,4) > 0.9; %BAD EMPTY WELLS???

mm=mean(newdat(emptyWells,:));
ss=std(newdat(emptyWells,:));

newz=bsxfun(@minus,newdat,mm);
newz=bsxfun(@rdivide,newz,ss);

figure; subplot(2,2,1);
plot((oldz(~emptyWells,1)+oldz(~emptyWells,2))/2,newz(~emptyWells,4),'r.');
xlabel('Old Z-score 1 hour','FontSize',18);
ylabel('New Z-score 1 hour','FontSize',18);

subplot(2,2,2);
plot((oldz(~emptyWells,3)+oldz(~emptyWells,4))/2,newz(~emptyWells,5),'r.');
xlabel('Old Z-score 6 hour','FontSize',18);
ylabel('New Z-score 6 hour','FontSize',18);

subplot(2,2,3);
plot(newz(~emptyWells,3),newz(~emptyWells,4),'r.'); hold on;
plot(newz(emptyWells,3),newz(emptyWells,4),'k.');
xlabel('New Z-score 1 hour Smad2','FontSize',18);
ylabel('New Z-score 1 hour Smad4','FontSize',18);


subplot(2,2,4);
plot((newz(~emptyWells,1)+newz(~emptyWells,2))/2,newz(~emptyWells,5),'r.'); hold on;
plot((newz(emptyWells,1)+newz(emptyWells,2))/2,newz(emptyWells,5),'k.');
xlabel('New Z-score 6 hour Smad2','FontSize',18);
ylabel('New Z-score 6 hour Smad4','FontSize',18);

saveas(gcf,'CherryPickSummary.eps','psc2');
