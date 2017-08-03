function [fullstatsR] =  clonal_ucolanalysisRANDOM(nms,dir,index1,N,cfpthresh,areathresh,normto)
% plot the average intensity of the marker as a function of colony size
% N - colont size to consider
clear tmp
clear tmp2
clear tmp3
clear rawdata
clear err

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
fullstatsR = cell(1,size(nms,2));
for k=1:size(nms,2)
    M = N;%max(M)
    totalcolonies = zeros(M,1);       
    totalcells=zeros(M,1);    
    col = colonies{k};    
    clonalstats = struct;
    clonalstats.mixRand = [];
    clonalstats.nolbl = [];
    clonalstats.onlylbl = [];
    clonalstats.totalcols = [];
     q = 1;
     for ii=1:length(col)
         in = colonies{k}(ii).imagenumbers;     % here need to filter image numbers to use
         nc = col(ii).ncells;
         cleanup = col(ii).data(:,3); % cell area of each cell
         [r,~]=find(cleanup<areathresh);% thow small stuff
         col(ii).data(r,:) = [];
         nc = size(col(ii).data,1);
             if ~isempty(col(ii).data) && (nc == N) % if after cleanup the new colony is the required size
                 totalcolonies(nc)=totalcolonies(nc)+1;
                 % totalcells(nc)=totalcells(nc)+nc;
                 % if size(index1,2) == 1
                 tmp = col(ii).data(:,index1(1)); % get the values of cy5 in this colony
                 tmp3 = col(ii).data(:,index1(2)); % get the values of cfp in this colony
                 if ~isempty(normto)
                 tmp = col(ii).data(:,index1(1))./col(ii).data(:,normto); % normalized data
                 end
                 % find how many out of cells within this colony are cfp positive
                 var = tmp3(tmp3>=cfpthresh);
                 cfppos = size(var,1);
                 % now need to randomly pick cells out of this mixed colony
                 % and look at the expression of cdx2 there
                 
%                  disp(tmp)
%                  disp(cfppos)
                 if (cfppos>0) && (cfppos<size(tmp,1)) % this is for the data on mixed colonies
                    % disp('here1');
                     topull=randi([1 cfppos],cfppos,1);   % generate column of integer numbers of size cfppos
                     topull1=unique(topull);              % make sure they are qunique
                     topull2 = (1:N)';
                     topull2(topull1) = 0;
                     restofcells = nonzeros(topull2);
                     clonalstats.mixRand(q,1) = mean(tmp(topull1));    % mean expression of cy5 in the randomly selected cells within that colony
                     clonalstats.mixRand(q,2) = mean(tmp(restofcells));% mean expression of cy5 in the remaining cells of that colony
                 
                     clonalstats.stdR(q,1) = std(tmp(topull1));    % err in the randomly selected cells within that colony
                     clonalstats.stdR(q,2) = std(tmp(restofcells));% err in the remaining cells of that colony
                 end
                 if cfppos == 0 % this is for the fully cfp- cells
                    %  disp('here2');
                     clonalstats.nolbl(q,1)=mean(tmp);
                 end
                 if cfppos == size(tmp,1) % this is for the fully cfp+ cells
                    %  disp('here3');
                     clonalstats.onlylbl(q,1) = mean(tmp);
                 end
                 if ~(cfppos == size(tmp,1)) && ~(cfppos == 0) && ~(cfppos>0) && ~(cfppos<size(tmp,1))
                     disp('unaccounted condition')
                 end                 
                 q = q+1;
            %disp(q);                 
             end           
   
     end
  clonalstats.totalcols = nonzeros(totalcolonies);
  if isempty(clonalstats.mixRand)
      clonalstats.mix = 0;
  end
  if isempty(clonalstats.onlylbl)
      clonalstats.onlylbl = 0;
  end
  if isempty(clonalstats.nolbl)
      clonalstats.nolbl = 0;
  end
  
   disp(['Dataset ' num2str(k)]);
   regrouped = size(nonzeros(clonalstats.mixRand(:,1)),1)+size(nonzeros(clonalstats.nolbl(:,1)),1)+size(nonzeros(clonalstats.onlylbl(:,1)),1);
   disp(['colonies regruped into stats =' num2str(regrouped)]);
   disp(['total colonies found =' num2str(nonzeros(totalcolonies))]);
  
   fullstatsR{k} = clonalstats;
   

end

end