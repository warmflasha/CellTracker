function tabulatemRNAposfish (dir1, sn, ch)
%sn: no. of samples
%n_ch = Channels to be analysed


%%

dir = dir1;
mkdir ([dir '/results']);

for i = 1:length(ch)
file  =  sprintf('/spots_quantify_t7ntch%d/data/FISH_spots_data_new.mat', ch(i));
ldfile{i} = strcat(dir1, file);
load (ldfile{i});
csi{i} = enlistcell_new;
om{i} = One_mRNA;
end


%%
sno = 1;
for sno = 1:sn
clear finalmat csi_ch csi_f;   

for nch= 1:length(ch)
csi_ch{nch} = csi{nch};
csi_f{nch} = csi_ch{nch}(sno);
end

finalmat(:,1:2) = [csi_f{1}{1}(:,2), csi_f{1}{1}(:,1)];

col_no = 3;
for nch = 1:length(ch)
    finalmat(:,col_no) = [csi_f{nch}{1}(:,4)/om{nch}];
    col_no = col_no + 1;
end
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
  
  
  filen = sprintf('fishseg%02d', j);
  filenld = strcat(dir,'/masks/', filen);
  load (filenld);
 
  s = regionprops(LcFull, 'Centroid');

for i = fmstart:k
    
    finalmat(i,col_no:col_no+1) = s(finalmat(i,2)).Centroid;
   
end

   
   fmstart = k+1; 
    
end

filename = sprintf('/sample%dresults.mat', sno);
filename = strcat(dir, '/results/', filename);

save(filename, 'finalmat');
end
