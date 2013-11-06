%zero bad stuf

for ii=1:51
    dd=sdata{ii}.zsc;
    nc=sdata{ii}.ncells;
    

    hitsmaybeneg = xor(dd(:,1) < -3,dd(:,2) < -3) & ((dd(:,1) < -3.5 & nc(:,1) > 0) | (dd(:,2) < -3.5 & nc(:,2) > 0));
    hitsmaybepos = xor(dd(:,3) > 2,dd(:,4) > 2) & ((dd(:,3) > 2.5 & nc(:,3) > 0) | (dd(:,3) > 2.5 & nc(:,4) > 0));
    
    inds = find(dd < -15 & nc > 0);
    if ~isempty(inds)
        disp(['Bad stuff found, plate: ' int2str(ii) '.']);
    end
    
    sdata{ii}.hits1partial=hitsmaybeneg;
    sdata{ii}.hits6partial=hitsmaybepos;
end
    