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
   
  clear all
  
   for i = 1:3
   all = 1 ;   
  
   file = sprintf('sample%dresults.mat', i);
   load(file);
   nel = size(finalmat,1);
   ch1a(all:nel) = finalmat(:,3);
   m = 1;
   chm{m}(i) = mean(finalmat(:,3));
    m = m+1;
   
   ch2a(all:nel) = finalmat(:,4);
   chm{m}(i) = mean(finalmat(:,4));
   
   m = m+1;
   ch3a(all:nel) = finalmat(:,5);
   chm{m}(i) = mean(finalmat(:,5));
   all = nel+1;
   end
   
   %%
   figure;
   for i = 1:3
       
   subplot(1,3,i);
   
   bar(chm{i});
   xlab = {'NC', 'MP1', 'MP2'};
   set(gca, 'XTickLabel', xlab, 'XTick', 1:numel(xlab));
   
   tit = sprintf('ch%d', i);
   
   title(tit, 'FontSize', 14, 'FontWeight', 'bold');
   
   end
   
   
   
   
   
   
   