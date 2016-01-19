function stats = coCultureStats(matfile1,matfile2)

pp=load(matfile1,'peaks');
peaks1 = pp.peaks;

if isempty(peaks1{end})
peaks1=peaks1(1:(end-1));
end

pp=load(matfile2,'peaks');
peaks2 = pp.peaks;

if isempty(peaks2{end})
peaks2=peaks2(1:(end-1));
end

for ii=1:length(peaks1)
dat1 = peaks1{ii}; dat2 = peaks2{ii};
[stats(ii).nn1 stats(ii).nnid1]=getNNDists(dat1(:,1:2));
stats(ii).mnn1 = mean(stats(ii).nn1);

[stats(ii).nn2 stats(ii).nnid2]=getNNDists(dat2(:,1:2));
stats(ii).mnn2 = mean(stats(ii).nn2);


stats(ii).pairwise_nns = getNNDistsPairs(dat1(:,1:2),dat2(:,1:2));
stats(ii).mnn12 = mean(stats(ii).pairwise_nns.dists12);
stats(ii).mnn21 = mean(stats(ii).pairwise_nns.dists21);

end



function [nndists, nnids]=getNNDists(dat)

dists = ipdm(dat);
[nndists, nnids]= sort(dists);
nndists = nndists(2,:);
nnids = nnids(2,:);

function pairwise_nns=getNNDistsPairs(dat1,dat2)

dists = ipdm(dat1,dat2);
[t1, t2]=sort(dists);

pairwise_nns.dists12=t1(2,:);
pairwise_nns.ids12=t2(2,:);

[t1, t2]=sort(dists,2);
pairwise_nns.dists21=t1(:,2);
pairwise_nns.ids21=t2(:,2);