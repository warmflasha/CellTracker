function plate=analyzeCytooPlate(matfile,mincellbig)

if ~exist('mincellbig','var')
    mincellbig=1500;
end

pp=load(matfile);
c2g=plotgoodcolonies(pp.colonies);

gind=[c2g.good];
gind = gind > 0;
nc=[c2g.ncells];
den=[c2g.density];
ar=[c2g.aspectRatio];
plot(nc,den,'r.')

rad=[c2g.radius];

hist(rad(gind),50);
bigcells = nc > mincellbig;

col1000=gind & rad > 1200 & bigcells;
col500 = gind & rad < 1200 & rad > 700;
col250 = gind & rad < 650 & rad > 300;
colSm=gind & rad < 250;


inds1000=find(col1000); 
inds500=find(col500);
inds250=find(col250); 
indsSm=find(colSm);

plate.inds1000=inds1000;
plate.inds500=inds500;
plate.inds250=inds250;
plate.indsSm=indsSm;

[plate.ndrSm plate.eRRndrSm]=runAvgOverColonies(c2g,indsSm,5,0,2);
[plate.ndr250 plate.eRRndr250]=runAvgOverColonies(c2g,inds250,10,0,2);
[plate.ndr500 plate.eRRndr500]=runAvgOverColonies(c2g,inds500,15,0,2);
[plate.ndr1000 plate.eRRndr1000]=runAvgOverColonies(c2g,inds1000,30,0,2);

[plate.ncrSm plate.eRRncrSm]=runAvgOverColonies(c2g,indsSm,5,0,1);
[plate.ncr250 plate.eRRndr250]=runAvgOverColonies(c2g,inds250,10,0,1);
[plate.ncr500 plate.eRRndr500]=runAvgOverColonies(c2g,inds500,15,0,1);
[plate.ncr1000 plate.eRRndr1000]=runAvgOverColonies(c2g,inds1000,30,0,1);

[plate.bDataSm plate.ebDataSm]=runAvgOverColonies(c2g,indsSm,5,0,3);
[plate.bData250 plate.ebData250]=runAvgOverColonies(c2g,inds250,10,0,3);
[plate.bData500 plate.ebData500]=runAvgOverColonies(c2g,inds500,15,0,3);
[plate.bData1000 plate.ebData1000]=runAvgOverColonies(c2g,inds1000,30,0,3);


save(matfile,'plate','-append');

% figure; plot(r1000B(:,1),'r.-'); hold on;
% plot(r1000B(:,2),'g.-');
% %plot(r1000B(:,3),'b.-');
% 
% figure; %subplot(2,2,1); 
% hold on;
% title('1000um');
% plot(r1000(:,1),'r.-'); hold on;
% plot(r1000(:,2),'g.-');
% %plot(r1000(:,3),'b.-');
% if exist('leg','var');
%     legend(leg);
% end

% 
% subplot(2,2,2); hold on;
% title('500um');
% plot(r500(:,1),'r.-');
% plot(r500(:,2),'g.-');
% plot(r500(:,3),'b.-');
% 
% subplot(2,2,3); hold on;
% title('250um');
% plot(r250(:,1),'r.-');
% plot(r250(:,2),'g.-');
% plot(r250(:,3),'b.-');
% 
% subplot(2,2,4); hold on;
% title('Small');
% plot(rSm(:,1),'r.-');
% plot(rSm(:,2),'g.-');
% plot(rSm(:,3),'b.-');

% allcells250=[];allcellsSm=[]; allcells500=[]; allcells1000=[];
% 
% for ii=1:length(indsSm)
%     mmSm(ii,:)=meannonan(c2g(indsSm(ii)).data(:,[6 8 10]));
%     allcellsSm=[allcellsSm; c2g(indsSm(ii)).data(:,6)./c2g(indsSm(ii)).data(:,5)];
% end
% 
% for ii=1:length(inds250)
%         mm250(ii,:)=meannonan(c2g(inds250(ii)).data(:,[6 8 10]));
%         allcells250=[allcells250; c2g(inds250(ii)).data(:,6)./c2g(inds250(ii)).data(:,5)];
% end
% 
% for ii=1:length(inds500)
%     allcells500=[allcells500; c2g(inds500(ii)).data(:,6)./c2g(inds500(ii)).data(:,5)];
% end
% 
% for ii=1:length(inds1000)
%     allcells1000=[allcells1000; c2g(inds1000(ii)).data(:,6)./c2g(inds1000(ii)).data(:,5)];
% end
% figure; subplot(1,2,1); hist(mmSm(:,1),50);    title('Bra -- Small colonies');
% subplot(1,2,2); hist(mm250(:,1),50);        title('Bra -- 250um colonies');
% 
% figure; subplot(2,2,1); hist(allcells1000,100); %set(gca,'xscale','log');
% subplot(2,2,2); hist(allcells500,100);%set(gca,'xscale','log');
% subplot(2,2,3); hist(allcells250,100);%set(gca,'xscale','log');
% subplot(2,2,4); hist(allcellsSm,100);%set(gca,'xscale','log');

% figure;
% for ii=1:length(inds1000)
%     subplot(4,4,ii); hold on;
%     plot(c2g(inds1000(ii)).bdata(1:30,6),'r.-');
%     plot(2*c2g(inds1000(ii)).bdata(1:30,8),'g.-');
%     plot(c2g(inds1000(ii)).bdata(1:30,10),'b.-');
%     
% end
