function peaks=removeDuplicateCells(peaks,acoords)

for ii=1:length(peaks)
    if  ~isempty(peaks{ii})
        od=peaks{ii};
        indstoremove1=od(:,1) < acoords(ii).wside(1);
        od(indstoremove1,:)=[];
        indstoremove2=od(:,2) < acoords(ii).wabove(1);
        od(indstoremove2,:)=[];
        peaks{ii}=od;
    end
end