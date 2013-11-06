function sdata=AnalyzePlates(platenum,showfig,cscale)

if ~exist('showfig','var')
    showfig = 1;
end

%matfile directory
direc = 'C:\DATA\Screen\IndividualSiRNA';
lo = 100; hi = 3000;
ncells=zeros(384,4); mm=zeros(384,4);

pn = int2str(platenum);
if length(pn)==1
    pn = ['0' pn];
end


if platenum==1
    inds2use=3:6;
else
    inds2use=7:10;
end

for ii=1:4
    mat1=[direc filesep 'out_' int2str(inds2use(ii)) '.mat'];
    [mm(:,ii) ncells(:,ii)]=readPlateData(mat1);
end

sdata.mm = mm;
sdata.ncells = ncells;

mnc = mean(ncells);
snc = std(ncells);

nczsc = bsxfun(@minus,ncells,mnc);
nczsc = bsxfun(@rdivide,nczsc,snc);

sdata.ncellszsc=nczsc;

checkgood = abs(nczsc) < 3.5 & ncells > 50;
sdata.checkgood = checkgood;
%checkgood = sum(checkgood,2);
goodcells1 = checkgood(:,1) & checkgood(:,2);
goodcells6 = checkgood(:,3) & checkgood(:,4);

sdata.goodcells1 = goodcells1;
sdata.badcells1 = find(~goodcells1);

sdata.goodcells6 = goodcells6;
sdata.badcells6 = find(~goodcells6);

%Make plate layouts
if showfig
figure; 
for ii = 1:4
    nc=reshape(ncells(:,ii),24,16)';
    nc(:,end+1)=zeros(16,1);
    nc(end+1,:)=zeros(1,25);
    subplot(2,2,ii);
    pcolor(nc); shading flat;
end

if ~exist('cscale','var')
    cscale=[0.9 1.6];
end

figure; 
for ii = 1:4
    nc=reshape(mm(:,ii),24,16)';
    nc(:,end+1)=zeros(16,1);
    nc(end+1,:)=zeros(1,25);
    subplot(2,2,ii);
    pcolor(nc); shading flat; caxis(cscale);
end
end

%find the hits
mmavg=[mean(mm(goodcells1,1)) mean(mm(goodcells1,2)) mean(mm(goodcells6,3)) mean(mm(goodcells6,4))];
mmstd=[std(mm(goodcells1,1)) std(mm(goodcells1,2)) std(mm(goodcells6,3)) std(mm(goodcells6,4))];
zsc=(mm-mmavg(ones(384,1),:))./mmstd(ones(384,1),:);

sdata.zsc=zsc;


h1 = zsc(:,1) < -3 & zsc(:,2) < -3 & goodcells1;
h2 = zsc(:,3) > 2 & zsc(:,4) > 2 & goodcells6;
sdata.hits1 = h1;
sdata.hits6 = h2;

l1=0.9:0.1:1.4;
l2=-4:1:4;

if showfig
figure; 
subplot(2,2,1);
plot(mm(goodcells1,1),mm(goodcells1,2),'r.');
hold on;plot(l1,l1,'k-');
plot(mm(47,1),mm(47,2),'c.'); plot(mm(48,1),mm(48,2),'g.');
xlabel('Ratio -- trial 1','FontSize',18);
ylabel('Ratio -- trial 2','FontSize',18);
title('1 hour time points','FontSize',18);

subplot(2,2,2);
plot(mm(goodcells6,3),mm(goodcells6,4),'r.');
hold on;plot(l1,l1,'k-');
plot(mm(47,3),mm(47,4),'c.'); plot(mm(48,3),mm(48,4),'g.');

xlabel('Ratio -- trial 1','FontSize',18);
ylabel('Ratio -- trial 2','FontSize',18);
title('6 hour time points','FontSize',18);

subplot(2,2,3);
plot(zsc(goodcells1,1),zsc(goodcells1,2),'r.');
hold on;plot(l2,l2,'k-');
plot(zsc(47,1),zsc(47,2),'c.'); plot(zsc(48,1),zsc(48,2),'g.');

xlabel('Zscore -- trial 1','FontSize',18);
ylabel('Zscore -- trial 2','FontSize',18);
title('1 hour time points','FontSize',18);

subplot(2,2,4);
plot(zsc(goodcells6,3),zsc(goodcells6,4),'r.');
hold on;plot(l2,l2,'k-');
plot(zsc(47,3),zsc(47,4),'c.'); plot(zsc(48,3),zsc(48,4),'g.');

xlabel('Zscore -- trial 1','FontSize',18);
ylabel('Zscore -- trial 2','FontSize',18);
title('6 hour time points','FontSize',18);

bc1=sdata.badcells1;
bc2=sdata.badcells6;
wn=mkWellNames;
figure; subplot(1,2,1); title('Bad cells, 1 hour time point');
plot(ncells(bc1,1),ncells(bc1,2),'r.'); hold on;
for ii=1:length(bc1)
    text(ncells(bc1(ii),1),ncells(bc1(ii),2),wn(bc1(ii)),'Color','b');
end

subplot(1,2,2); title('Bad cells, 6 hour time point');
plot(ncells(bc2,3),ncells(bc2,4),'r.'); hold on;
for ii=1:length(bc2)
    text(ncells(bc2(ii),3),ncells(bc2(ii),4),wn(bc2(ii)),'Color','b');
end
end

function [mm ncells]=readPlateData(mat1)

load(mat1);
mm=zeros(384,1);
ncells=zeros(384,1);

for ii=1:384
    if ~isempty(outdatall{ii})
        mm(ii)=meannonan(outdatall{ii}(:,6)./outdatall{ii}(:,7));
        ncells(ii)=size(outdatall{ii},1);
    end
end