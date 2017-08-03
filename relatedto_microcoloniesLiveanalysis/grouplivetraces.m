%% scripts to bin the signaling data: split traces based on the last time point signaling level for the same colony size
% Get means over time but separately for different colony sizes
% new figure for each new colony size ( data drawn from multiple .mat
% files)

fr_stim = 12;        %22(jan8data)  %38 nov12data              %16 feb16     16 (july7 data)   %(fr_stim = 12) july 26 data 
delta_t = 17;%15       % 12 min       % 5 minutes               15min             17min              (17min)
p = fr_stim*delta_t/60;
trajmin = 20;%30
tpt = 84;%100 81 99 83
strdir = '*_40Xset2_BGan.mat';%outFebsetBGan
ff = dir(strdir);%'*_60X_testparam_allT.mat'ff = dir('*60Xjan8_R*.mat');
C1 = {'c','b','r'};% for colorcoding colony size ( if look at means of all nc-colonies
signalbin = [];
notbinned = [];
errbin = [];
signthresh =0.9; % look at all colonies of size nc

clear traces
clear traces_one
clear traces_two
clear traces_three
clear a
totalcol = zeros(6,1);
C = {'c','r'};
q = 1;

nc = 1;                       % look at nc-cell colonies
N = 20;  
                    % how many last time point to average in order to sort into beans

for k=1:length(ff)
    outfile = ff(k).name; %nms{k};
    load(outfile,'colonies');
    if ~exist('colonies','var');
        disp('does not contain colonies structure')
    end
    numcol = size(colonies,2); % how many colonies were grouped within the frame
    traces = cell(1,numcol);
    nucgfp= cell(1,numcol);
    for j = 1:numcol
        if size(colonies(j).ncells_actual,1)>fr_stim  %&&             % new segmentation
            colSZ1 =colonies(j).ncells_actual(fr_stim) ;
            colSZ2 =colonies(j).ncells_actual(end-1) ;   % check what was the colony size at the last timepoint

            % new segmentation
            %colSZ =colonies(j).numOfCells(timecolSZ-1) ;                                                      % for old mat files analysis
            if colSZ1 == nc %&& (colSZ2 == nc)
                jj =1;
                
                traces{j} = colonies(j).NucSmadRatio;                                                 % colonies(j).NucSmadRatio(:)
                %traces{j} = colonies(j).NucOnlyData;   % to look at only
                %nuclear GFP times the cell nucArea
                %traces{j} = colonies(j).NucSmadRatioOld;                                                     % for old mat files analysis
                sz = size(traces{j},2);
                for h = 1:size(traces{j},2)
                    [r,~] = find(isfinite(traces{j}(:,h)));                  %
                    dat = zeros(tpt,1);
                    dat(r,1) = traces{j}(r,h);
                    s = mean(nonzeros(dat(end-N:(end-1))));                       % take the mean of the last chunk of N time points
                    if length(nonzeros(dat))>trajmin && (s < signthresh);      % mean(nonzeros(dat(end-15:end))))  FILTER OUT SHORT TRAJECTORIES  and select the ones that end low in signaling
                      totalcol(nc) = totalcol(nc)+1;
                        jj =1;
                        disp(['filter trajectories below' num2str(trajmin)]);
                        disp(['use' num2str(length(nonzeros(dat)))]);
                        figure(jj), plot(dat,'-*','color',C{jj});hold on          % here plot the traces that met the condition
                        signalbin{jj}(:,q+sz-1) = dat;                            % here store the traces which meat condition
                        errbin{jj}(:,q+sz-1) = std(nonzeros(dat((end-N):end-1))); % here store the sd for traces that meat condition
                        
                        % disp(q+sz-1)
                        xx = size(dat,1)-1;
                        yy = dat(end-1);%traces{k}(end,h);
                        text(xx,yy,[num2str(s) ',pos' num2str(outfile(1:2))],'color','m','fontsize',11);%
                        figure(jj) ,hold on
                        
                    end
                     if length(nonzeros(dat))>trajmin && (s >= signthresh);       % FILTER OUT SHORT TRAJECTORIES  and select the ones that end low in signaling
                        jj =2;
                        disp(['filter trajectories below' num2str(trajmin)]);
                        disp(['use' num2str(length(nonzeros(dat)))]);
                        figure(jj), plot(dat,'-*','color',C{jj});hold on          % here plot the traces that met the condition
                        signalbin{jj}(:,q+sz-1) = dat;                            % here store the traces which meat condition
                        errbin{jj}(:,q+sz-1) = std(nonzeros(dat((end-N):end-1))); % here store the sd for traces that meat condition
                        % disp(q+sz-1)
                        xx = size(dat,1)-1;
                        yy = dat(end-1);%traces{k}(end,h);
                        text(xx,yy,[num2str(s) ',pos' num2str(outfile(1:2))],'color','m','fontsize',11);%
                       figure(jj) ,hold on
                       ylim([0 2.5]);
                       xlim([0 (tpt+10)]);
                       ylabel('mean Nuc/Cyto smad4  ');
                       xlabel('frames');
                    end
                    
                end
                q = q+sz;
                
                
                
            end
        end
    end                       % new segmentation
end

 figure(1)
 ylim([0 2.5]);
 xlim([0 (tpt+10)]);
 ylabel('mean Nuc/Cyto smad4  ');
 xlabel('frames');
                       
%end
% figure, plot(1:size(totalcol,1),totalcol,'r-*','markersize',18,'linewidth',3);
% xlabel('cells per colony','fontsize',20);
% ylabel('totla colonies','fontsize',20);
% title('colony size distribution','fontsize',20)
%% average those trajectoris
tpt = tpt-1;
vect = (1:tpt)';
binmean = zeros(tpt,size(signalbin,2));
err =zeros(tpt,size(signalbin,2)); 

for j =1:size(binmean,2)                  % remove Nans
for k=1:size(binmean,1)
    for jj=1:size(signalbin{j},2)
   if (isfinite(signalbin{j}(k,jj))==0) || signalbin{j}(k,jj)< 0.5 || signalbin{j}(k,jj)>1.85 % to remove signaling values that come from long-traced junk
           %if (isfinite(signalbin{j}(k,jj))==0) || signalbin{j}(k,jj)< 100  || signalbin{j}(k,jj)>900 % to remove signaling values that come from long-traced junk

           signalbin{j}(k,jj) = 0;
   end
    end
end
end
% average over cells
for j =1:size(binmean,2)% loop over the bins;         
for k=1:size(binmean,1)
    binmean(k,j) = mean(nonzeros(signalbin{j}(k,:)));   % mean over nonzero values of signaling at each time point
    err(k,j) = std(nonzeros(signalbin{j}(k,:)));
    
end
end
% if nc == 2
%     binmean2 = binmean;
%     err2 = err;
%     signalbin2 = signalbin;
% end
% save('FebSet_stats','binmean','err','binmean2','err2','signalbin','signalbin2')
%% plot means for each bin in signaling
vect = (1:tpt)';
colormap = colorcube;
C = {'c','r'};


b = [signthresh];
label = {'signal below','signal above'};


for j = 1:size(binmean,2)
figure(11), errorbar(binmean(:,j),err(:,j),'-.','color',C{j},'linewidth',1.5); hold on%colormap(j+5,:)
ylim([0.3 1.8]);
xlim([0 105])
ylabel('mean Nuc/Cyto smad4  ');
xlabel('frames');
text(vect(end)+0.2*j,binmean(end,j)+0.1*j,[ label(j) num2str(b(1))],'color',C{j},'fontsize',20);%['mean ColCdx2 ' num2str(colonies2(j).cells(h).fluorData(1,end))]
title('One-cell colonies','fontsize',20);
if nc == 2
title('Two-cell colonies','fontsize',20);
end

figure(12), plot(vect,binmean(:,j),'-.','color',C{j},'linewidth',2); hold on%colormap(j+5,:)
ylim([0.3 1.8]);
xlim([0 115])
ylabel('mean Nuc/Cyto smad4  ');
xlabel('frames');
text(vect(end)+0.2*j,binmean(end,j)+0.1*j,[ label(j) num2str(b(1))],'color',C{j},'fontsize',20);%['mean ColCdx2 ' num2str(colonies2(j).cells(h).fluorData(1,end))]
title('One-cell colonies','fontsize',20);
if nc == 2
title('Two-cell colonies','fontsize',20);
end
% sd of individual trajectories during the last N time points
figure(13), scatter((1:size(nonzeros(errbin{j}))),nonzeros(errbin{j}),[],C{j},'linewidth',2); hold on%colormap(j+5,:)
%legend(label{j}); hold on%['mean ColCdx2 ' num2str(colonies2(j).cells(h).fluorData(1,end))]

ylim([0 0.4]);
xlim([0 30])
ylabel(['SD during last  ' num2str(N) '  time points']);
title('One-cell colonies','fontsize',20);
box on
if nc == 2
title('Two-cell colonies','fontsize',20);
end

end
figure(13),legend(label); 