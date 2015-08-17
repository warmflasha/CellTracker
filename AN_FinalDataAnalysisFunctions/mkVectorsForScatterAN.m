% generic function to obtain the vectors for scatter plots
% length of index2 specifies whether the vectors are normalized to Dapi or
% not.
% input argument is peaks of any matfile
% the last vector (d or valuescmap) may be used if the scatter plot needs to
% be colorcoded by the expression of the index2(3) peaks column.

function [b,c,ncell] = mkVectorsForScatterAN(peaks,col,index2)% need to also inut the col

%figure(2); hold on;
colors = colorcube(12);

for ii=1:length(col)
    ncell = size(col(ii).data,1);
    if ncell > 12
        ncell = 12;
    end
    b = col(ii).data(:,index2(1))./col(ii).data(:,5);
    c = col(ii).data(:,index2(2))./col(ii).data(:,5); 
    ncell(ii,1) = size(col(ii).data,1);
  %  plot(b,c,'.','Color',colors(ncell,:));
end
    
% 
% valuescmap = [];
% valuesone =[];
% valuestwo=[];
% valuesthree=[];
% 
% for ii=1:length(peaks)
%     if ~isempty(peaks{ii})
%         if length(index2)==1
%             valuesone =[valuesone; peaks{ii}(:,index2(1))];
%         else
%             valuestwo =[valuestwo; peaks{ii}(:,index2(1))./peaks{ii}(:,5)];          % data plotted on the x axis
%             valuesthree =[valuesthree; peaks{ii}(:,index2(2))./peaks{ii}(:,5)];      % data plotted on the y axis
%            
%            
%            valuescmap = [valuescmap; peaks{ii}(:,1)]; % coordinate x of each cell in each image
%            
%         %-----------------------------------------
%           %C = cat(1,col(:).data);
%         for k=1:length(valuescmap)
%                for j=1:length(col)
%                   if col(j).data(:,1) == valuescmap(k)
%                    % a = find(col(j).data(:,1) == valuescmap(k));
%                    % if a == 1
%                        valuescmapnew(k,1) = size(col(j).data,1);
%                    end
%                end
%            end
%         %----------------------------------------
%           
%         end
%     end
%     
% end
% a = valuesone;
% b = valuestwo;
% c = valuesthree;
% csz = valuescmap; % to which size colony a given cell from peaks belongs
end