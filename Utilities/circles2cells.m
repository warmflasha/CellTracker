function cellCenters=circles2cells(centers,radii)

ratio_cutoff = 1.4;


cc=centers;
rr=radii';

ncirc=length(rr);

dists = ipdm(cc);

dist_ratios = dists./rr(ones(ncirc,1),:);

counted = zeros(ncirc,1);

q=1;

inds = find(dist_ratios < ratio_cutoff);

[px, py]=ind2sub(size(dist_ratios),inds);
qq=1;
while sum(counted) < ncirc
    q=find(counted==0,1,'first');
    groups{qq}=q;
    [indstoadd, locp]=ismember(groups{qq},px);
    locp = locp(locp>0);
    while sum(indstoadd) > 0
        groups{qq}=unique([groups{qq}, py(locp)']);
        counted(py(locp))=1;
        px(locp)=[]; py(locp)=[];
        [indstoadd, locp]=ismember(groups{qq},px);
        locp = locp(locp>0);
    end
    
    [indstoadd, locp]=ismember(groups{qq},py);
    locp = locp(locp > 0);
    while sum(indstoadd) > 0
        groups{qq}=unique([groups{qq}, px(locp)']);
        counted(px(locp))=1;
        px(locp)=[]; py(locp)=[];
        [indstoadd, locp]=ismember(groups{qq},py);
        locp = locp(locp>0);     
    end
    qq=qq+1;
end

cellCenters = zeros(length(groups),2);

for ii=1:length(groups)
    cellCenters(ii,:)=mean(cc(groups{ii},:),1);
end


