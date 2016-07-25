function [cellstoremove] = removebadDAPIcells(peaks, dapimax)
% make a single column vector from the dapi values for all cells
% find the roes that have high dapi
% return those row linear values as the variable celltoremove

nlines=zeros(length(peaks),1);
for ii=1:length(peaks)
    nlines(ii)=size(peaks{ii},1);
end
alllines = sum(nlines);
alldata=zeros(alllines,1);
q=1;

for ii=1:length(peaks)
    if ~isempty(peaks{ii})
        alldata(q:(q+nlines(ii)-1))=peaks{ii}(:,5);%
        q=q+nlines(ii);
    end
    
end
cellstoremove = find(alldata> dapimax);


end