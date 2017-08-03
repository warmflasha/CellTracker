function [colonylocalstats,col] = getlocalneighbordata(matfile,cfpthresh, brachan,cfpchan,greenchan,D)
 
 load(matfile,'peaks','plate1');%sortGFPS4cfp_70to30_cfpGfpRfpCy5   sortBetaCatpluri_CFPdiff_June29th2017LiveImgCFPGFPRFPCY5   
  clear localstats
 localstats = struct;
colonylocalstats = struct;
col = plate1.colonies;
localstats.nuctocyto = [];
for ii=1:length(col)   
         ncell = size(col(ii).data,1); % keep the size of the original colony, since the cells are there  they are just not uniquely labeled
        if ~isempty(col(ii).data) 
           d = ipdm(col(ii).data(:,1:2),'Subset','Maximum','Limit',D); 
           % each row is a row of distances between the cell, numbered by
           % that row and all the other cells in the colony
          
           for celln=1:ncell% get the stats from the ipdm matrix for colony ii and each cell neighborhood within that colony
               [~,b]=find((isfinite(d(celln,:)))==1);% column number b is the cell within the colony, which falls within D from given cell              
               localstats(celln).nearcellstats(1:size(b,2),1:2) = col(ii).data(b,1:2);% xy of neighbors
               localstats(celln).currcell = col(ii).data(celln,1:2);% current cell around which the neighborhood is calculated
               localstats(celln).braincell = col(ii).data(celln,brachan);
               localstats(celln).A = col(ii).data(celln,3);
               localstats(celln).greenincell = col(ii).data(celln,greenchan);
               if size(greenchan,2)>1
               localstats(celln).nuctocyto = (col(ii).data(celln,greenchan(1)))/(col(ii).data(celln,greenchan(2)));
               end
               localstats(celln).cfpclose = size(nonzeros(col(ii).data(b,cfpchan)>cfpthresh),1);% absolute number of cfp+ cells in the neighborhood
               localstats(celln).cfpclosefr = size(nonzeros(col(ii).data(b,cfpchan)>cfpthresh),1)/size(col(ii).data(b,cfpchan),1);% wht fraction of neighboring cells are cfp+
               localstats(celln).pluriclosefr = (1-localstats(celln).cfpclosefr);% fraction of same cell neighbors (pluri cells) in the neighborhood
           end
           colonylocalstats(ii).allstats = localstats;
        end
        
       % colonylocalstats(ii).allstats = localstats;
         
end