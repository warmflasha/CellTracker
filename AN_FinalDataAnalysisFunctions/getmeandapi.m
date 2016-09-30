function [dapimeanall,ncells] = getmeandapi(nms,dir,index, dapimax)
% get the mean value of DAPI for all files in nms cell array
dapimean = zeros(size(nms,2),1);
ncells = zeros(size(nms,2),1);
dapimax = 60000;
for k=1:size(nms,2)        % load however many files are in the nms string
    filename{k} = [dir filesep  nms{k} '.mat'];
    load(filename{k},'peaks','plate1');
    disp(['loaded file: ' filename{k}]);
    nlines=zeros(length(peaks),1);
    for ii=1:length(peaks)
        nlines(ii)=size(peaks{ii},1);
    end
    alllines = sum(nlines);
    alldata=zeros(alllines,1);
    q=1;
    
    for ii=1:length(peaks)
        if ~isempty(peaks{ii})
            if (size(index,2) == 1)
                alldata(q:(q+nlines(ii)-1))=peaks{ii}(:,index(1));%
                q=q+nlines(ii);
            end
            
            if size(index,2)>1
                alldata(q:(q+nlines(ii)-1))=peaks{ii}(:,index(2));%
                q=q+nlines(ii);
                
            end
            
            
        end
        
        cellstoremove = find(alldata>dapimax)  ;%%
        alldata(cellstoremove) = [];
        dapimean(k,1) = mean(alldata);
        ncells(k,1) = size(alldata,1);
    end
end
    dapimeanall = mean(dapimean);
    
end
