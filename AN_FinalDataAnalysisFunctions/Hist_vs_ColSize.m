function [data] =  Hist_vs_ColSize(nms,nms2,dir,index1,param1,dapimax,scaledapi,flag,ucol)

% plot the distributions of mean marker expression as a function of colony size

clear tmp
clear tmp2
clear data
colormap = colorcube;
data = cell(1,size(nms,2));
clear dapi
if (scaledapi == 1) 
for k=1:size(nms2,2)
[dapi(k),ncells] = getmeandapi(nms(k),dir,index1, dapimax);
disp(['cells found' num2str(ncells) ]);
disp(['dapi mean value' num2str(dapi(k)) ]);
end
dapiscalefactor = dapi/dapi(1);
end
if (scaledapi == 0) 
dapiscalefactor = ones(1,size(nms,2));
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
            if size(index1,2) >1              % to look at normalized data
                tmp = col(ii).data(:,index1(1))./(col(ii).data(:,index1(2))./dapiscalefactor(k));  % assign the value of the normalized intensity in specific channel to tmp;
                tmp2(nc,q:q+size(tmp,1)-1) = tmp; % add the elements tmp, corresponding to the same colony size, into the tmp2          
            end 
            if size(index1,2) == 1              % to look at raw data distributions
                tmp = (col(ii).data(:,index1(1))./dapiscalefactor(k));  % assign the value of the normalized intensity in specific channel to tmp;
                tmp2(nc,q:q+size(tmp,1)-1) = tmp; % add the elements tmp, corresponding to the same colony size, into the tmp2          
            end 
            
        end
        q = q+size(tmp,1);
        
    end
    data{k} = tmp2;
end
%plot histograms
xbin = (0:(round(max(max(tmp2(ucol,:))))/20):round(max(max(tmp2(ucol,:)))));% ucol
%xbin = (0:((round(mean(nonzeros(tmp2(ucol,:)))))/10):(round(mean(nonzeros(tmp2(ucol,:))))));
%xbin = (0:1:10);

if flag == 1
    for ii=1:ucol
        if ~isempty(nonzeros(tmp2(ii,:)))
            figure(ii),histogram(nonzeros(tmp2(ii,:)),xbin,'FaceColor',colormap(ii,:),'Normalization','probability');legend(num2str(ii));hold on %'Normalization','probability'
            xlabel(param1);
            ylabel('Frequency');
            h1 = figure(ii);
            h1.CurrentAxes.FontSize = 20;
            h1.CurrentAxes.LineWidth = 2;
            ylim([0 ((size(nonzeros(tmp2(ii,:)),1)))]); %
            ylim([0 0.6]);
            xlim([0 round(max(max(tmp2(ii,:))))]);
            title(['Distributions by colony size (normalized)' nms2 ])
        end
    end
    
    figure(ucol+1), histogram(nonzeros(tmp2(1,:)),xbin,'FaceColor',colormap(1,:),'Normalization','probability');hold on
    figure(ucol+1), histogram(nonzeros(tmp2(ucol,:)),xbin,'FaceColor',colormap(ucol,:),'Normalization','probability');
    xlabel(param1);
    ylabel('Frequency');
    h1 = figure(ucol+1);
    ylim([0 ((size(nonzeros(tmp2(1,:)),1)))]); %
    ylim([0 0.6]);
    xlim([0 round(max(max(tmp2(1,:))))]);
    title(['Distributions by colony size (normalized)' nms2 ])
    legend('1-cell', [ num2str(ucol) '-cell' ]);
    h1.CurrentAxes.FontSize = 18;
    h1.CurrentAxes.LineWidth = 2;
    
end

end