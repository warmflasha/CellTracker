% function specifically for the analysis of the mixed experiment data
% need to sort the cells based on them being expressing dapi only or dapi
% and H2B

% to id the esicells, need to find cells that have intensity in the green
% channel < 2000 ( and any DAPI intensity)
% to id the h2b cells, need to find cells taht have 488 intensity > 5000
% 


function [alldata,alldata2] = SortCellsbyExpressionAN(peaks,col,index2,flag,ind,dapimax)% need to also input the col

if flag == 0   % if flag ==0, generate the third column with the colony size that the cell belongs to; necessary if want to colo the scatter plot with col size
%  colors = colormap(cool);% needed if the coloring is done by colony size
%  colors = colors(1:16:end,:);% colorcube;cool;autumn;jet;hsv   i
 q = 1;
 s = 1;
 alldata = zeros(size(peaks,2),5);
 alldata2 = zeros(size(peaks,2),5);
 for ii=1:length(col)
          ncell = size(col(ii).data,1);
          if ncell > 8
              ncell = 8;
          end
          if any(col(ii).data(:,5)>dapimax)
              continue
          end
          
          b = col(ii).data(:,index2(1));% expression of H2B marker
          c = col(ii).data(:,index2(2));% dapi in the same colony
          d = col(ii).data(:,ind(1))./col(ii).data(:,5);      
          e = col(ii).data(:,ind(2))./col(ii).data(:,5); 
          if (any(b<2500)==1) && (any(b>2500)==1) % if the same colony has the h2b and the esi cell
          
          mixcol4 = col(ii).data(:,ind(1))./col(ii).data(:,5); 
          mixcol5 = col(ii).data(:,ind(2))./col(ii).data(:,5);
          mixcol1 = col(ii).data(:,index2(1));
          mixcol2 = col(ii).data(:,index2(2));
          currmix =size(mixcol1,1); 
          
          alldata2(s:(s+currmix-1),1) = mixcol1;
          alldata2(s:(s+currmix-1),2) = mixcol2;
          alldata2(s:(s+currmix-1),3) = ncell;
          alldata2(s:(s+currmix-1),4) = mixcol4;
          alldata2(s:(s+currmix-1),5) = mixcol5;
          s = s+currmix;
          end
          
          
          currb = size(b,1);
          currc = size(c,1);
          currd = size(d,1);
          curre = size(e,1);
          
          
          
          alldata(q:(q+currb-1),1)=b;
          alldata(q:(q+currc-1),2)=c;
          alldata(q:(q+currb-1),3)=ncell;
          alldata(q:(q+currd-1),4)=d;
          alldata(q:(q+curre-1),5)=e;
          
          
          
          q=q+currb; % currb should be equal to currc, so one increment is enough
         % plot(b,c,'.','Color',colors(ncell,:),'MarkerSize',10); hold on; % 
          
 end
 
end
if flag == 1      % if flag ==1, generate 2 columns with combined peaks data col1 = values of all peaks column(index2(1)); this is useful if want to colorcode the scatter plot by the value of the datapoint
  q = 1;
  alldata = zeros(size(peaks,2),2);
 for ii=1:length(col)
          ncell = size(col(ii).data,1);
          if ncell > 8
              ncell = 8;
          end
          
          
          b = col(ii).data(:,ind(1))./col(ii).data(:,5);
          c = col(ii).data(:,ind(2))./col(ii).data(:,5);
          
          if any(col(ii).data(:,5)>dapimax)
              continue
          end
          
          currb = size(b,1);
          currc = size(c,1);
          
          alldata(q:(q+currb-1),1)=b;
          alldata(q:(q+currc-1),2)=c;
                   
          q=q+currb; % currb should be equal to currc, so one increment is enough
         % plot(b,c,'.','Color',colors(ncell,:),'MarkerSize',10); hold on; % 
 end
 
end