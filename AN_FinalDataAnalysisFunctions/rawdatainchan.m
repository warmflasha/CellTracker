function [chandata] = rawdatainchan(nms,dir,index)
% get the matrix where each column is a different channel, each row is cell
chandata = cell(size(nms,2),1);

for k=1:size(nms,2)        % load however many files are in the nms string
    filename{k} = [dir filesep  nms{k} '.mat'];
    load(filename{k},'peaks');
    disp(['loaded file: ' filename{k}]);
    nlines=zeros(length(peaks),1);
    for ii=1:length(peaks)
        nlines(ii)=size(peaks{ii},1);
    end
    alllines = sum(nlines);
    alldata=zeros(alllines,size(index,2));% each column will be corresponding to the channel
    q=1;
    
    for ii=1:length(peaks)
        if ~isempty(peaks{ii})
            
                alldata(q:(q+nlines(ii)-1),1:size(index,2))=peaks{ii}(:,index);%
                q=q+nlines(ii);
                  
                       
        end
        
    end
    chandata{k} = alldata;
end
    
    
end
