function cellmeans = getSignalingMeans(matfile,intervals,mintrajlength)

load(matfile,'notbinned','fr_stim','delta_t');

nframes = size(notbinned{1},1);
allframes = 1:nframes;

for ii = 1:length(intervals)
    %convert intervals to frames
    int_now = intervals{ii};
    int_now = int_now*60/delta_t; %into frames
    int_now = fr_stim+int_now; %shift relative to fr_stim
    inds_now = allframes > int_now(1) & allframes < int_now(2);
    for jj = 1:3
        datanow = notbinned{jj}(inds_now,:);
        inds_notzero = datanow > 0;
        trajlength = sum(inds_notzero);
        cellstouse = trajlength > mintrajlength;
        cellmeans{ii,jj} = meannozero(datanow(:,cellstouse));
    end
end
        
    
    
    
    


