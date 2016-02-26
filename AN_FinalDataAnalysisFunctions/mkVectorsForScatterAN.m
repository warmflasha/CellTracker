% generic function to obtain the vectors for scatter plots
% length of index2 specifies whether the vectors are normalized to Dapi or
% not.
% input argument is peaks of any matfile
% the last vector (d or valuescmap) may be used if the scatter plot needs to
% be colorcoded by the expression of the index2(3) peaks column.

function [alldata] = mkVectorsForScatterAN(peaks,col,index2,flag)% need to also input the col

if flag == 0   % if flag ==0, generate the third column with the colony size that the cell belongs to; necessary if want to colo the scatter plot with col size
%  colors = colormap(cool);% needed if the coloring is done by colony size
%  colors = colors(1:16:end,:);% colorcube;cool;autumn;jet;hsv   i
 q = 1;
 alldata = zeros(size(peaks,2),3);
 for ii=1:length(col)
          ncell = size(col(ii).data,1);
          if ncell > 8
              ncell = 8;
          end
          b = col(ii).data(:,index2(1))./col(ii).data(:,5);
          c = col(ii).data(:,index2(2))./col(ii).data(:,5);
          
          currb = size(b,1);
          currc = size(c,1);
          
          alldata(q:(q+currb-1),1)=b;
          alldata(q:(q+currc-1),2)=c;
          alldata(q:(q+currb-1),3)=ncell;
          
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
          b = col(ii).data(:,index2(1))./col(ii).data(:,5);
          c = col(ii).data(:,index2(2))./col(ii).data(:,5);
          
          currb = size(b,1);
          currc = size(c,1);
          
          alldata(q:(q+currb-1),1)=b;
          alldata(q:(q+currc-1),2)=c;
                   
          q=q+currb; % currb should be equal to currc, so one increment is enough
         % plot(b,c,'.','Color',colors(ncell,:),'MarkerSize',10); hold on; % 
 end
 
end
   
% if flag == 1 
% valuescmap = [];
% valuesone =[];
% valuestwo=[];
% valuesthree=[];
% alldata = [];
% for ii=1:length(peaks)
%     if ~isempty(peaks{ii})
%         if length(index2)==1
%             valuesone =[valuesone; peaks{ii}(:,index2(1))];
%         else
%             valuestwo =[valuestwo; peaks{ii}(:,index2(1))./peaks{ii}(:,5)];          % data plotted on the x axis
%             valuesthree =[valuesthree; peaks{ii}(:,index2(2))./peaks{ii}(:,5)];      % data plotted on the y axis
% %                      
% %         %----------------------------------------
%           
%         end
%     end
%     
% end
% alldata = valuesone;
% alldata(:,1) = valuestwo;
% alldata(:,2) = valuesthree;
% end
end