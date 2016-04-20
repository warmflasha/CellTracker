% plot the average intensity of the marker as a function of colony size
function [rawdata] =  Intensity_vs_ColSize(nms,nms2,dir,index1,param1,dapimax)
clear tmp
for k=1:size(nms,2)
    filename{k} = [dir filesep  nms{k} '.mat'];
    load(filename{k},'plate1');
    colonies{k} = plate1.colonies;
    if ~exist('plate1','var')
        [colonies{k}, ~]=peaksToColonies(filename);
    end
    M(k) = max([colonies{k}.ncells]);
end

for k=1:size(nms,2)
    M = max(M);
    totalcolonies = zeros(M,1);
    rawdata = zeros(M,1);
    tmp2 = zeros(M,1);
    totalcells=zeros(M,1);
    
    col = colonies{k};
    
    for ii=1:length(col)
        a = any(col(ii).data(:,5)>dapimax);
        if ~isempty(col(ii).data) && a==0;
            nc = col(ii).ncells;
            
            totalcolonies(nc)=totalcolonies(nc)+1;
            % totalcells(nc)=totalcells(nc)+nc;
            if size(index1,2) == 1
            tmp = col(ii).data(:,index1(1)); %assign the value of the normalized intensity in specific channel to tmp;
            tmp2(nc) = tmp2(nc) + sum(tmp); % add the elements tmp, corresponding to the same colony size, into the tmp2
            end
            if size(index1,2) >1
           tmp = col(ii).data(:,index1(1))./col(ii).data(:,5); %assign the value of the normalized intensity in specific channel to tmp;
          %tmp = col(ii).data(:,index1(1)).*col(ii).data(:,index1(2));
            tmp2(nc) = tmp2(nc) + sum(tmp); % add the elements tmp, corresponding to the same colony size, into the tmp2
            end
            
        end
        
        
    end
    
    for l=1:length(totalcolonies)
        
        totalcells(l)=totalcolonies(l)*l;
    end
    
    for j=1:length(tmp2)
        rawdata(j) = tmp2(j)./totalcells(j); % average intensity of expression ( devide by the total number of cells of each colony size)
    end
    
    figure(6);subplot(1,size(nms2,2),k),  plot(rawdata,'b*'); legend(nms2{k});
    xlabel('Colony size');
    ylabel(['Expression of ',(param1),'marker']);
    xlim([0 15]);
    
end