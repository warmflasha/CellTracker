%%
load FISH_spots_data_new.mat;

 cellsampleinfo = enlistcell_new;
 
 %% equalising sample no.
%  for i = 2:3
%      u = unique(cellsampleinfo{i}(:,2));
%      lastval = u(end-3);
%      a = (cellsampleinfo{i}(:,2)<lastval);
%      cellsampleinfo{i} = cellsampleinfo{i}(a,:);
%  
%  end
 
 %%
 
 for i = 1:numel(cellsampleinfo)
     mdet{i} = sum(cellsampleinfo{i}(:, 3));
 end
 
 
    for i = 1:length(mdet)
        quant(i) = mdet{i};
    end
    
    bar(quant, 0.5);
    Labels = {'fish1', 'fish2', 'fish3', 'fish4'};
   set(gca, 'XTick', 1:4, 'XTickLabel', Labels);
   
   
   
  %%
   
   for i = 1:4
       
   subplot(2,2,i);
   cl = cellsampleinfo{i}(:,1);
   cls = size(cl,1);
   plot(1:cls, cellsampleinfo{i}(:,3));
   xlabel(Labels(i));
   
   end
   
   
   
   
   