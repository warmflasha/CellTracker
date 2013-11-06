function groups=getUniqueBounds(bnd,allPoints)

allboundpoints=unique(bnd(:));
assignments=1:length(allboundpoints);


nclass=1;
groups{1}=bnd(1,:);

for ii=2:size(bnd,1)
    disp(int2str(ii));
    isinclass=zeros(nclass,1);
    for jj=1:nclass
        isinclass(jj)=sum(ismember(bnd(ii,:),groups{jj})) > 0;
    end
    
    inds=find(isinclass);
    
    if isempty(inds)
        nclass=nclass+1;
        groups{nclass}=bnd(ii,:);
    elseif length(inds)==1
        groups{inds}=[groups{inds} bnd(ii,:)];
    else
        inds=sort(inds);
        groups{inds(1)}=[groups{inds(1)} bnd(ii,:)];
        for jj=2:length(inds)
            groups{inds(1)}=[groups{inds(1)} groups{inds(jj)}];
        end
        for jj=2:length(inds)
            groups(inds(jj))=[];
            nclass=nclass-1;
        end
    end
   
end


for ii=1:nclass
    groups{ii}=unique(groups{ii});
    nc(ii)=length(groups{ii});
end
[~, inds]=sort(nc,'descend');

groups=groups(inds);


if exist('allPoints','var')
    ps={'g.','r.','b.','m.','c.','y.'};
    figure; hold on;
    plot(allPoints(:,1),allPoints(:,2),'k.');
end
if nclass > 6
cc=colorcube(nclass+1);
for ii=1:nclass
    plot(allPoints(groups{ii},1),allPoints(groups{ii},2),'.','Color',cc(ii,:));
end
else
   for ii=1:nclass
    plot(allPoints(groups{ii},1),allPoints(groups{ii},2),ps{ii});
   end
end

