function [celltoremovefin] = removebadDAPIcells(peaks,index, dapimax, chanmax)
% make a single column vector from the dapi values for all cells
% find the roes that have high dapi
% return those row linear values as the variable celltoremove
%dapimax = 60000;

nlines=zeros(length(peaks),1);%length(peaks)
for ii=1:length(peaks) %length(peaks)
    nlines(ii)=size(peaks{ii},1);
end
alllines = sum(nlines);
alldata=zeros(alllines,1);
alldata1=zeros(alllines,1);
q=1;

for ii=1:length(peaks)%length(peaks)
    if ~isempty(peaks{ii})
        if (size(index,2) == 1) || (isempty(chanmax)==1)
            alldata(q:(q+nlines(ii)-1))=peaks{ii}(:,index(1));%
            q=q+nlines(ii);
        end
        %cellstoremove = find(alldata> dapimax);
        if size(index,2)>1
            alldata(q:(q+nlines(ii)-1))=peaks{ii}(:,3);% to get rid of the large area cells
            alldata1(q:(q+nlines(ii)-1))=peaks{ii}(:,index(1));%
            q=q+nlines(ii);
            
        end
        
        
    end
    
    cellstoremove = find(alldata>dapimax(1))  ;%% 
    %cellstoremove2 = find(alldata> dapimax(2))  ;%%
    cellstoremove1 =  find(alldata1> chanmax);
    celltoremovefin = unique(cat(1,cellstoremove,cellstoremove1));
    
end