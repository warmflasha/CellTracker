function [alldata,allcfp,allbetacat,maxcolsz,frac] = getdat_scatterLargeColonies(peaks,col,index2,flag,flag2,dapimax,dapiscalefactor,thresh)% need to also input the col
% if the cells were stained with dapi as well 

clear allcfp
clear allbetacat
allcfp = struct;
allbetacat = struct;
frac = struct;
if flag == 0   % if flag ==0, generate the third column with the colony size that the cell belongs to; necessary if want to colo the scatter plot with col size
    %  colors = colormap(cool);% needed if the coloring is done by colony size
    %  colors = colors(1:16:end,:);% colorcube;cool;autumn;jet;hsv   i
    q = 1;
    alldata = zeros(size(peaks,2),3);
    allcolsz = cat(1,col.ncells);
    maxcolsz = max(allcolsz);
    %thresh = [dapi rfp gfp bra]
    % need to leave cells that are either >dapithresh&&>rfpthresh, and >dapithresh&&>gfpthresh
    for ii=1:length(col)
         ncell = size(col(ii).data,1); % keep the size of the original colony, since the cells are there  they are just not uniquely labeled
        if ~isempty(col(ii).data) && (~isempty(ncell))
           
%             [dapionly,~]=find(col(ii).data(:,5)>thresh(1));%
%             [rfponly,~]=find(col(ii).data(:,10)>thresh(2));
%             [gfponly,~]=find(col(ii).data(:,8)>thresh(3));            
%             cfpcells = intersect(dapionly,gfponly);
%             betacetcells = intersect(dapionly,rfponly);
%             betacetcells = rfponly;
             [cfpcells,~]=find(col(ii).data(:,5)>thresh(1) & col(ii).data(:,8)>thresh(3));%
              [betacetcells,~]=find(col(ii).data(:,5)>thresh(1) & col(ii).data(:,10)>thresh(2));
            
            % here insert the struct to store the fraction of cfp+ cells in a
            % colony
          if ~isempty(betacetcells) && ( ~isempty(cfpcells)) % ensure looking at mixed colonies  
            frac(ii).cfppos = size(cfpcells,1)/ncell;%(size(cfpcells,1)+size(betacetcells,1))
            frac(ii).sz = size(cfpcells,1)+size(betacetcells,1);% size after finding the positive cells
            frac(ii).sztrue = ncell;% original colony size based on only dapi segm.            
            frac(ii).dat = col(ii).data;
            frac(ii).Mbra = mean(col(ii).data((betacetcells),6)./col(ii).data((betacetcells),5));% get the mean of bra in beta cat cells in that colony 
            frac(ii).Mbetacat = mean(col(ii).data((betacetcells),8)./col(ii).data((betacetcells),5));% get the mean of betaCat in beta cat cells in that colony 
            braPos = find(col(ii).data((betacetcells),6)./col(ii).data((betacetcells),5)>thresh(4));
            frac(ii).MbraPos = size(braPos,1)/(size(betacetcells,1));  % 
            
            allcfp(ii).dat = col(ii).data(sort(cfpcells),:);
                allcfp(ii).n = ncell;
                allbetacat(ii).dat = col(ii).data((betacetcells),:);
                allbetacat(ii).n = ncell;
                disp(['this colony has :' num2str(size(cfpcells,1)) 'cfp cells and' num2str(size(betacetcells,1)) ' betaCat cells']);
                toleave = cat(1,cfpcells,betacetcells);
                col(ii).data = col(ii).data(sort(toleave),:); % leave only the cells that have are either cfp or beta-cat based on coexpression
                a = any(col(ii).data(:,3)>dapimax);
                % if (a == 0) && ((ncell <= N+0.30*N) && (ncell >= N-0.30*N)) %ncell<=N   ((ncell == N) || (ncell == N+0.20*N) || (ncell == N-0.20*N))
                
                if flag2 == 1
                    b = col(ii).data(:,index2(1))./(col(ii).data(:,5)/dapiscalefactor);
                    c = col(ii).data(:,index2(2))./(col(ii).data(:,5)/dapiscalefactor);
                end
                if flag2 == 0 || (isempty(flag2)==1)
                    b = col(ii).data(:,index2(1));
                    c = col(ii).data(:,index2(2));
                end
                currb = size(b,1);
                currc = size(c,1);
                alldata(q:(q+currb-1),1)=b;
                alldata(q:(q+currc-1),2)=c;
                alldata(q:(q+currb-1),3)=ncell;
                q=q+currb; % currb should be equal to currc, so one increment is enough
                % plot(b,c,'.','Color',colors(ncell,:),'MarkerSize',10); hold on; %
                %end
            end
        end
    end
end
  

end