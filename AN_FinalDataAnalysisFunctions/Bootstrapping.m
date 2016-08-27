%A script to perform bootstrapping on the data in peaks
%in order to get a better estimate of the error
% function [aver, err] = BootStrapping(matfile) % returns a scalar, which is the value of the error across all the peaks in a given matfile, calculated using bootstrapping
% Niter - number of times to pool from the data set
% nsample - size of the sample to pool from the data set
% load outall_1_new.mat;
% useonly - if want to exclude some mages from the analysis; not really used
% col - which column to normalize by the DAPI column in the 'peaks' cell array). The
% numbering refers to the numbering of peaks{ii}(:,col) and needs to be
% verified before plotting , i.e. which channel corresponds to which
% exactly column in peaks cell array.
function [aver, err, alldata]=Bootstrapping(peaks,Niter,nsample,col,dapimax, chanmax,dapimeanall)%

cellstoremove = removebadDAPIcells(peaks,col, dapimax, chanmax);% the cellstoremove are the rows that need to be removed since they represent very bright DAPI values

nlines=zeros(length(peaks),1);
for ii=1:length(peaks)
    nlines(ii)=size(peaks{ii},1);
end
alllines = sum(nlines);
alldata=zeros(alllines,1);
q=1;

for ii=1:length(peaks)
    if ~isempty(peaks{ii})
        if length(col)==1
            alldata(q:(q+nlines(ii)-1))=peaks{ii}(:,col);%make a single column vector from all the data (normalized intensity of col.6 in peaks to dapi (col. 5) in peaks
            
        else
            alldata(q:(q+nlines(ii)-1))=peaks{ii}(:,col(1))./dapimeanall;%dapimeanall peaks{ii}(:,col(2))
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