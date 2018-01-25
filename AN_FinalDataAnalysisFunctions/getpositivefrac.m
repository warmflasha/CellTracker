
function [fractions]=getpositivefrac(nms,nms2,thresh,index,chandata,normto)

clear fractions

fractions = zeros(1,size(nms2,2));
for k=1:size(nms,2)
    d1 = chandata{k}(:,index)./chandata{k}(:,normto);  %
    alldat = size(d1,1);
    [r1,~] = find(d1>thresh);   %
    onlycdx2 = size((r1),1);
    fractions(1,k) = onlycdx2/alldat;
end

end