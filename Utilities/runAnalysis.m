parpool(6)
%%
%touse = [1:3 5:6];
touse = 0:4;
parfor ii=1:5  
    %runSegmentCellsZstack('.',ii,0,'setUserParamKMCFP',['OVCA_' int2str(ii) '.mat']);
    runSegmentCellsZstack('.',touse(ii),[0 1],'setUserParamKMCFP',['H8_' int2str(touse(ii)) '.mat']);
end
%%
xx = [1:3 5 6];

for ii=1:5
    file1 = ['OVCA_' int2str(xx(ii)) '.mat'];
    file2 = ['NOF_' int2str(xx(ii)) '.mat'];
    stats=coCultureStats(file1,file2);
    mnn12(ii,:)=[stats.mnn12];
    mnn21(ii,:)=[stats.mnn21];
     mnn1(ii,:)=[stats.mnn1];
     mnn2(ii,:)=[stats.mnn2];
     smad2(ii,:)=peaksAverage(file2,[6 7]);
end

figure; hold on;
plot(mean(mnn1)); plot(mean(mnn2)); 
plot(mean(mnn12)); 
plot(mean(mnn21)); 
legend({'OVCA to closest OVCA', 'NOF to closest NOF', 'NOF to closest OVCA', 'OVCA to closest NOF'});
%plot(mean(smad2));
xx=(0:119); %*10/60;
figure; plotyy(xx,mean(smad2),xx,mean(mnn1)); hold on;
figure; plot(mean(mnn12));
%%
ff = readAndorDirectory('.');
%%
pos = 5; time = 40; 

for ii=0:3
img{ii+1}=imread(getAndorFileName(ff,pos,time,[],ii));
end
showImg(img(1:2)); hold on;

load(['OVCA_' int2str(pos) '.mat']);
plot(peaks{time+1}(:,1),peaks{time+1}(:,2),'c.');

load(['NOF_' int2str(pos) '.mat']);
plot(peaks{time+1}(:,1),peaks{time+1}(:,2),'m.');
