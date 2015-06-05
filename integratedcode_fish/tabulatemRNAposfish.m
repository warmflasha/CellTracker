function tabulatemRNAposfish (dir1, sn, n_ch)
%sn: no. of samples
%n_ch = no. of channels


%%

dir = dir1;
mkdir ([dir '/results']);

for i = 1:n_ch
ldfile{i} =  sprintf('/Users/sapnac18/Desktop/CellTracker/cell_images/fish2/moreimages/spots_quantify_t7ntch%d/data/FISH_spots_data_new.mat', i);
load (ldfile{i});
csi{i} = enlistcell_new;
om{i} = One_mRNA;
end


%%

for sno = 1:sn
clear finalmat;    

csi_ch1 = csi{1};
csi_ch2 = csi{2};

csi_f1 = csi_ch1{sno};
csi_f2 = csi_ch2{sno};

finalmat(:,1:4) = [csi_f1(:,2), csi_f1(:,1), csi_f1(:,4)/om{1}, csi_f2(:,4)/om{2}];
%%
% finalmat contains required details of all the cells in one sample. 
% Column 1: Frame in which cell is identified
% Column 2: Cell no. 
% Column 3: No. of mRNA's identified in channel 1
% Column 4: No. of mRNA's identified in channel 2
% Column 5: x position of cell's centroid.
% Column 6: y position of cell's centroid. 
% finalmat is then saved in a mat file: sample(sampleno)results.mat under
% the variable name finalmat.


%%

frames = unique(finalmat(:,1));
jstart = frames(1);
jlim = frames(end);

fmstart = 1;
for j = jstart:jlim
  clear s;  
  
  nrow = length(find(finalmat(:,1) == j));
 
  if( j == jstart)
      k = nrow;
  else
      k = k+nrow;
  end
  
  
  filen = sprintf('fishsegtest%02d', j);
  load (filen)
 
  s = regionprops(LcFull, 'Centroid');

for i = fmstart:k
    
    finalmat(i,5:6) = s(finalmat(i,2)).Centroid;
   
end

   
   fmstart = k+1; 
    
end

filename = sprintf('/sample%dresults.mat', sno);
filename = strcat(dir, '/results/', filename);

save(filename, 'finalmat');
end
