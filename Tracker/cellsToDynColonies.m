function cellsToDynColonies(matfile)

load(matfile,'cells','peaks');
nc = length(cells);

pts = zeros(nc,2);
for ii=1:nc
    pts(ii,:) = mean(cells(ii).position);
end

allinds=NewColoniesAW(pts);
ngroups = max(allinds);
ncells = cell(ngroups,1);

%Make colony structure for the single cell algorythm
for ii=1:ngroups;
    cellstouse=allinds==ii;
    colonies(ii)=dynColony(cells(cellstouse));
    
  %  ncells(ii) = dynColonyStats(colonies(ii));
    
   
    ntimes = length(peaks); % number of time points
    Ntr = size(colonies(ii).cells,2); % number of trajectories
    onframesall = zeros(length(peaks),size(colonies(ii).cells,2));
    colsz_perframe = zeros(length(peaks),size(colonies(ii).cells,2));
    colsz_fin = zeros(length(peaks),1);
    
    for j = 1:Ntr
        one = (colonies(ii).cells(j).onframes)';
        onframesall(one(1):one(end),j) = one;
        
        for k = 1:ntimes
            colsz_perframe(k,j) = size(nonzeros(onframesall(k,j)),1);
            colsz_fin(k) = sum(colsz_perframe(k,:),2);
            
        end
        
        
    end
    
    ncells{ii} = colsz_fin;
    
    
end

save(matfile,'colonies','ncells','-append');