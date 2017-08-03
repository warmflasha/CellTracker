function [fullstats] =  clonal_plotselectedmixcol(nms,dir,index1,N,cfpthresh,areathresh,colnums,normto)
% plot the average intensity of the marker as a function of colony size
% N - colont size to consider
clear tmp
clear tmp2
clear tmp3
clear fullstats
clear cfppos

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
fullstats = cell(1,size(nms,2));
for k=1:size(nms,2)
    M = N;%max(M)
    totalcolonies = zeros(M,1);       
    totalcells=zeros(M,1);    
    col = colonies{k};    
    clonalstats = struct;
    clonalstats.mix = [];
    clonalstats.std = [];
    clonalstats.nolbl = [];
    clonalstats.onlylbl = [];
    clonalstats.totalcols = [];
    clonalstats.frequency = zeros(N,1);
    clonalstats.imgnum = [];
     q = 1;
     qq = 0;
     for ii=1:length(col)
         nc = col(ii).ncells;
         if (~isempty(col(ii).data) && (sum((ii == colnums{k})) >0)) %
             disp('met condition')
             tmp = col(ii).data(:,index1(1)); % get the values of cy5 in this colony
             tmp3 = col(ii).data(:,index1(2)); % get the values of cfp in this colony
             if ~isempty(normto)
                 tmp = col(ii).data(:,index1(1))./col(ii).data(:,normto); % normalized data
             end
             % find how many out of cells within this colony are cfp positive
             var = tmp3(tmp3>=cfpthresh);
             cfppos = size(var,1);
             % now need to get the intensities in cy5 chanel of all
             % cells and if there are any cfppos cells there,
             % regroup the cells within this colony into cy5
             % intensity of cfp-pos cells and cfp- cells
             %                  disp(tmp)
             %                  disp(cfppos)
             if (cfppos>0) && (cfppos<nc) % this is for the data on mixed colonies
                  disp('here1');
                 clonalstats.mix(q,1) = mean(tmp(tmp3<cfpthresh));% mean expression of cy5 in the cfp-cells
                 clonalstats.mix(q,2) = mean(tmp(tmp3>=cfpthresh));% mean expression of cy5 in the cfp+cells
                 
                 clonalstats.std(q,1) = std(tmp(tmp3<cfpthresh));%  err in the cfp-cells
                 clonalstats.std(q,2) = std(tmp(tmp3>=cfpthresh));% err in the cfp+cells
                 %clonalstats.imgnum(q,1) = in(1);
                 clonalstats.colnum(q,1) = ii;
                 %clonalstats.frequency(cfppos,1) = clonalstats.frequency(cfppos,1)+1;
             end
             if cfppos == 0 % this is for the fully cfp- cells
                 %  disp('here2');
                 clonalstats.nolbl(q,1)=mean(tmp);
             end
             if cfppos == nc % this is for the fully cfp+ cells
                 %  disp('here3');
                 clonalstats.onlylbl(q,1) = mean(tmp);
             end
             if ~(cfppos == nc) && ~(cfppos == 0) && ~(cfppos>0) && ~(cfppos<nc)
                 disp('unaccounted condition')
             end
             
             q = q+1;
             %disp(q);
             
         end
         
         
         
         
     end
  clonalstats.totalcols = nonzeros(totalcolonies);
  if isempty(clonalstats.mix)
      clonalstats.mix = 0;
  end
  if isempty(clonalstats.onlylbl)
      clonalstats.onlylbl = 0;
  end
  if isempty(clonalstats.nolbl)
      clonalstats.nolbl = 0;
  end
   disp(['Dataset ' num2str(k)]);
   regrouped = size(nonzeros(clonalstats.mix(:,1)),1)+size(nonzeros(clonalstats.nolbl(:,1)),1)+size(nonzeros(clonalstats.onlylbl(:,1)),1);
   disp(['colonies regruped into stats =' num2str(regrouped)]);
   disp(['total colonies found =' num2str(nonzeros(totalcolonies))]);
  
   fullstats{k} = clonalstats;
   

end

end