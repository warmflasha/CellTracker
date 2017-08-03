function [alldata,allcfp,allnoncfp,maxcolsz,frac] = getsorteddat_rfpcfpsorting_nodapi(peaks,col,index2,dapimax,thresh)% need to also input the col
% here both markers are tracked, cfp and rfp
% bra is the cy5 marker
% same as the betacat cells, the only thresh required os cfp and bra+
clear cfpcells
clear cfponly
clear restofcells
frac = struct;
allcfp = struct;
allnoncfp = struct;
    q = 1;
    alldata = zeros(size(peaks,2),3);
    allcolsz = cat(1,col.ncells);
    maxcolsz = max(allcolsz);
    %thresh = [cfp brathresh]
    % need to leave cells that are either >dapithresh&&>rfpthresh, and >dapithresh&&>gfpthresh
    for ii=1:length(col)
         ncell = size(col(ii).data,1); % keep the size of the original colony, since the cells are there  they are just not uniquely labeled
        if ~isempty(col(ii).data) && (~isempty(ncell))
           
            [cfponly,~]=find(col(ii).data(:,5)>thresh(1));
            cfpcells = cfponly;
            restofcells = find(col(ii).data(:,5)<thresh(1)); % non cfp-positive cells
            % here insert the struct to store the fraction of cfp+ cells in a
            % colony
          if ~isempty(cfpcells) && ( ~isempty(restofcells)) % ensure looking at mixed colonies  
            frac(ii).cfppos = size(cfpcells,1)/(ncell);%(size(cfpcells,1)+size(restofcells,1))
            frac(ii).sz = size(cfpcells,1)+size(restofcells,1);% size after finding the positive cells
            frac(ii).sztrue = ncell;% original colony size
            frac(ii).dat = col(ii).data;
            frac(ii).Mbra = mean(col(ii).data((restofcells),6));% get the mean of bra in non cfp-cells (unnormalized)
            frac(ii).Mgreen = mean(col(ii).data((restofcells),8));% get the mean of betacat or smad4 (unnormalized)
            braPos = find(col(ii).data((restofcells),6)>thresh(2));
            frac(ii).MbraPos = size(braPos,1)/(size(restofcells,1));% 
            frac(ii).nuccytoratio = mean(col(ii).data((restofcells),8)./col(ii).data((restofcells),9));% mean ratio of nuc:cyto in green chan (unnormalized)
            frac(ii).nuccytoinCFPcell = mean(col(ii).data((cfpcells),8)./col(ii).data((cfpcells),9));% mean ratio of nuc:cyto in green chan in cfp cells(unnormalized)

            
            allcfp(ii).dat = col(ii).data((cfpcells),:);
                allcfp(ii).n = ncell;
                allnoncfp(ii).dat = col(ii).data((restofcells),:);
                allnoncfp(ii).n = ncell;
                disp(['this colony has :' num2str(size(cfpcells,1)) 'cfp cells and' num2str(size(restofcells,1)) ' non-CFP cells']);                
                a = any(col(ii).data(:,3)>dapimax);
                % if (a == 0) && ((ncell <= N+0.30*N) && (ncell >= N-0.30*N)) %ncell<=N   ((ncell == N) || (ncell == N+0.20*N) || (ncell == N-0.20*N))
                                           
                    b = col(ii).data(:,index2(1));
                    c = col(ii).data(:,index2(2));
               
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
  

