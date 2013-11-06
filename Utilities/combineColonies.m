function peaks=combineColonies(peaks,seteq)

for ii=1:size(seteq,1)
    disp(int2str(ii));
    minnum=min(seteq(ii,:));
    maxnum=max(seteq(ii,:));
    for jj=1:length(peaks)
        if ~isempty(peaks{jj})
        inds=find(peaks{jj}(:,end)==maxnum);
        if ~isempty(inds)
            peaks{jj}(inds,end)=minnum;
        end
        end
    end
end
    