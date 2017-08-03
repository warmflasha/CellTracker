function [aver, err, alldata]=Bootstrap_noUcol(peaks,Niter,nsample,col,dapimax, chanmax)%

cellstoremove = removebadDAPIcells(peaks,col, dapimax, chanmax);% the cellstoremove are the rows that need to be removed since they represent very bright DAPI values

nlines=zeros(length(peaks),1);%length(peaks)
for ii=1:length(peaks)%length(peaks)
    nlines(ii)=size(peaks{ii},1);
end
alllines = sum(nlines);
alldata=zeros(alllines,1);
q=1;

for ii=1:length(peaks)%length(peaks)
    if ~isempty(peaks{ii})
        if length(col)==1
            alldata(q:(q+nlines(ii)-1))=peaks{ii}(:,col);%make a single column vector from all the data (normalized intensity of col.6 in peaks to dapi (col. 5) in peaks            
        else
            alldata(q:(q+nlines(ii)-1))=peaks{ii}(:,col(1));
        end
        q=q+nlines(ii);
    end
    
end
alldata(cellstoremove) = [];% remove the coresponding cells from the analysis
dat =zeros(Niter,1);

for j=1:Niter     % AW: the k-loop is not needed; the j loop can be removed too if replaced properly with ...
    for k=1:nsample
        dat(k,1) = alldata(randi(length(alldata))); % populate the sample with randomly chosen elements(with resampling)of the 'initial' vector
    end
    dataver(j)=mean(dat);
    
end
err  = std(dataver);
aver = mean(dataver);

end