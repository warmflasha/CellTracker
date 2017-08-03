function [rawdata1,err] =  Intensity_vs_ColSize2(nms,nms2,dir,index1,dapimax,chanmax,imN,scaledapi,flag1)
% this function is to plot the product of columns of peaks with indexes
% index1 : peaks(:,index1(1))*peaks(:,index1(2))

clear tmp
clear tmp2
clear rawdata
clear tmp3
clear err
rawdata1 = cell(1,size(nms,2));
err = cell(1,size(nms,2));

if scaledapi == 1
for k=1:size(nms2,2)
[dapi(k),ncells] = getmeandapi(nms(k),dir,index1, dapimax);
disp(['cells found' num2str(ncells) ]);
disp(['mean dapi' num2str(dapi(k)) ])
end
dapiscalefactor = dapi/dapi(1);
end
if scaledapi == 0
dapiscalefactor = ones(1,size(nms2,2));  
end
disp(dapiscalefactor);

for k=1:size(nms,2)
    filename{k} = [dir filesep  nms{k} '.mat'];
    load(filename{k},'plate1');
    colonies{k} = plate1.colonies;
    if ~exist('plate1','var')
        [colonies{k}, ~]=peaksToColonies(filename);
    end
    M(k) = max([colonies{k}.ncells]);
end
tmp3 = [];
for k=1:size(nms,2)
    M = max(M);
    totalcolonies = zeros(M,1);
    rawdata = zeros(M,1);
    tmp2 = zeros(M,1);
    totalcells=zeros(M,1);    
    col = colonies{k};   
     q = 1;
    for ii=1:length(col)
        a = any(col(ii).data(:,3)>dapimax(1));%%
        b = any(col(ii).data(:,index1(2))>chanmax);
         in = colonies{k}(ii).imagenumbers;
        if ~isempty(col(ii).data) && (flag1 == 1)% &&  (a==0); 
            nc = col(ii).ncells;            
            totalcolonies(nc)=totalcolonies(nc)+1;
            % totalcells(nc)=totalcells(nc)+nc;
            tmp = col(ii).data(:,index1(1)).*(col(ii).data(:,index1(2))*dapiscalefactor(k)); %assign the value of product to tmp;
            tmp2(nc) = tmp2(nc) + sum(tmp); % add the elements tmp, corresponding to the same colony size, into the tmp2
            sz = size(tmp,1);
            tmp3(q:(q+sz-1),1) = (tmp);% to store data for error
            tmp3(q:(q+sz-1),2) = nc;
            q = q+sz;
        end
        if ~isempty(col(ii).data) && (any(in(1)==imN)) &&  (a==0); % only specific image numbers  a==0
        nc = col(ii).ncells;            
            totalcolonies(nc)=totalcolonies(nc)+1;
            % totalcells(nc)=totalcells(nc)+nc;
            tmp = col(ii).data(:,index1(1)).*col(ii).data(:,index1(2)); %assign the value of product to tmp;
            tmp2(nc) = tmp2(nc) + sum(tmp); % add the elements tmp, corresponding to the same colony size, into the tmp2
        end        
    end 
    err1 = zeros(8,1);
    for j=1:8
        err1(j,1) = std(tmp3(tmp3(:,2)==j))./power(size(tmp3(tmp3(:,2)==j),1),0.5); % get the error for each colony size    
    end  
    for l=1:length(totalcolonies)        
        totalcells(l)=totalcolonies(l)*l;
    end    
    for j=1:length(tmp2)
        rawdata(j) = tmp2(j)./totalcells(j); % average intensity of expression ( devide by the total number of cells of each colony size)
    end
    
    rawdata1{k} = rawdata;
    err{k} = err1;
end
end