function [data] =  Hist_vs_ColSize(nms,nms2,dir,index1,param1,dapimax,usemeandapi,flag,ucol)

% plot the distributions of mean marker expression as a function of colony size

clear tmp
clear tmp2
clear data
colormap = colorcube;
data = cell(1,size(nms,2));
if usemeandapi == 1
    [dapimeanall,~] = getmeandapi(nms,dir,index1, dapimax);
end
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
    tmp2 = [];
    totalcells=zeros(M,1);
    
    col = colonies{k};
    q = 1;
    for ii=1:length(col)
        a = any(col(ii).data(:,3)>dapimax(1));%%      any(col(ii).data(:,index1(1))>dapimax(1))
        in = colonies{k}(ii).imagenumbers;
        tmp = [];
        if ~isempty(col(ii).data) && (a==0)
            nc = col(ii).ncells;
            totalcolonies(nc)=totalcolonies(nc)+1;
            % totalcells(nc)=totalcells(nc)+nc;
            if size(index1,2) == 1            % to look t raw channel data
                tmp = col(ii).data(:,index1(1));  % assign the value of the normalized intensity in specific channel to tmp;
                tmp2(nc,q:q+size(tmp,1)-1) = tmp; % add the elements tmp, corresponding to the same colony size, into the tmp2
            end
            if size(index1,2) >1              % to look at normalized data
                tmp = col(ii).data(:,index1(1))./col(ii).data(:,index1(2));  % assign the value of the normalized intensity in specific channel to tmp;
                tmp2(nc,q:q+size(tmp,1)-1) = tmp; % add the elements tmp, corresponding to the same colony size, into the tmp2
                
            end
            if usemeandapi == 1
                tmp = col(ii).data(:,index1(1))./dapimeanall; %assign the value of the normalized intensity in specific channel to tmp;
                %tmp = col(ii).data(:,index1(1)).*col(ii).data(:,index1(2));
                tmp2(nc,q:q+size(tmp,1)-1) = tmp;
            end
            
        end
        q = q+size(tmp,1);
        
    end
    data{k} = tmp2;
end
%plot histograms
%xbin = (0:(round(max(max(tmp2)))/10):round(max(max(tmp2))));
xbin = (0:((round(mean(nonzeros(tmp2(ucol,:))))+1)/20):(round(mean(nonzeros(tmp2(ucol,:))))+1));
%xbin = (0:1:10);

if flag == 1
    for ii=1:ucol
        if ~isempty(nonzeros(tmp2(ii,:)))            
            figure(ii),histogram(nonzeros(tmp2(ii,:)),xbin,'FaceColor',colormap(ii,:));legend(num2str(ii));hold on %'Normalization','probability'        
            xlabel(param1);
            ylabel('Frequency');
            h1 = figure(ii);
            h1.CurrentAxes.FontSize = 20;
            h1.CurrentAxes.LineWidth = 2;
            ylim([0 ((size(nonzeros(tmp2(ii,:)),1)))]); % 
            xlim([0 (round(mean(nonzeros(tmp2(ucol,:))))+1)]);
            title('Distributions by colony size (unnormalized)')
        end
    end
end
end