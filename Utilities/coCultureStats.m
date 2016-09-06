function stats = coCultureStats(matfile1,matfile2)

pp=load(matfile1,'peaks');
peaks1 = pp.peaks;

if exist('matfile2','var')
    pp=load(matfile2,'peaks');
    peaks2 = pp.peaks;
    coculture = true;
else
    coculture=false;
end

for ii=1:length(peaks1)
    dat1 = peaks1{ii}; 
    if ~isempty(dat1) 
        [stats(ii).nn1 stats(ii).nnid1]=getNNDists(dat1(:,1:2));
        stats(ii).mnn1 = mean(stats(ii).nn1);
        
        if coculture && ~isempty(peaks2{ii})
            dat2 = peaks2{ii};
            [stats(ii).nn2 stats(ii).nnid2]=getNNDists(dat2(:,1:2));
            stats(ii).mnn2 = mean(stats(ii).nn2);
            
            stats(ii).pairwise_nns = getNNDistsPairs(dat1(:,1:2),dat2(:,1:2)); 
            stats(ii).mnn12 = mean(stats(ii).pairwise_nns.dists12); %closest in file1 to each cell in file 2
            stats(ii).mnn21 = mean(stats(ii).pairwise_nns.dists21); %closest in file2 to each cell in file 1
            
            stats(ii).ratio1 = mean(stats(ii).pairwise_nns.dists21'./stats(ii).nn1);
            stats(ii).ratio2 = mean(stats(ii).pairwise_nns.dists12./stats(ii).nn2);
            
            if ii+1 < length(peaks) && ~isempty(peaks1{ii+1})
            inds = peaks1{ii}(:,4) > 0;
            newPos =peaks1{ii+1}(peaks1{ii}(inds,4),1:2);
            oldPos = peaks1{ii}(inds,1:2);
            vecs = newPos-oldPos;
            norm_vecs = sqrt(sum(vecs.*vecs,2));
            vecs = vecs./norm_vecs(:,[1 1]); % normalized velocity vector
            
            closestPos = dat2(stats(ii).pairwise_nns.ids21,1:2);
            closestPos=closestPos(inds,:);
            vecs2 = closestPos-oldPos;
            norm_vecs2 = sqrt(sum(vecs2.*vecs2,2));
            vecs2 = vecs2./norm_vecs2(:,[1 1]);
            
            stats(ii).dot_prod1 = sum(vecs.*vecs2,2);
            stats(ii).mdp1 = mean(stats(ii).dot_prod1);
            end
            
            
        end
    end
end
if ~exist('stats','var' )
    stats=[];
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