function [datafin] = GetDynamicColonyStats(matfile,fr_stim,delta_t,flag,colSZ,resptime,coloniestoanalyze)
% resptime = how many frames after stimulation want to look at the response
load(matfile,'colonies','ncells','peaks');

C = {'b','g','r','m'};
p = fr_stim*delta_t/60;
colors = colorcube(50);
ntimes = length(peaks);

colgr = size(colonies,2);% how many colonies were found
datafin = cell(colgr,1); % preallocate , more than necessary col 1 - means before, col2  mean after

for ii = 1:colgr;

    data_perframe = zeros(length(peaks),size(colonies(ii).cells,2));
    if ncells{ii}(fr_stim) == colSZ; % how many cells were there in the frame before stimulation of the i-th colony,
        
        Ntr = size(colonies(ii).cells,2); % number of trajectories
               
        for j = 1:Ntr
            one = (colonies(ii).cells(j).fluorData(:,2)./colonies(ii).cells(j).fluorData(:,3));
            tmp = (colonies(ii).cells(j).onframes)';
            data_perframe(tmp(1):tmp(end),j) = one;
            for k = 1:ntimes
                data_perframe(k,j) = data_perframe(k,j);
                
            end
            if ~isempty(fr_stim)
                datafin{ii}(j,1) = mean(nonzeros(data_perframe(1:fr_stim,j)));% mean before stimulation
                datafin{ii}(j,2) = mean(nonzeros(data_perframe((fr_stim+4):(fr_stim+resptime),j)));% mean after stimulation
                datafin{ii}(j,3) = abs(mean(nonzeros(data_perframe(1:fr_stim,j))) - mean(nonzeros(data_perframe((fr_stim+4):(fr_stim+25),j))));
            end
            if isempty(fr_stim)
                datafin{ii}(j,1) = mean(nonzeros(data_perframe(:,j)));% mean over all time points
                datafin{ii}(j,2) = mean(nonzeros(data_perframe(1:resptime,j)));
            end
        end
        % end
        if flag == 1 && ~isempty(fr_stim)
            
            p2 = ((resptime)*delta_t)/60;
            
            if size(nonzeros(datafin{ii}(:,2)),1)==size(nonzeros(datafin{ii}(:,2)),1)% isnan
                p2 = ((resptime)*delta_t)/60;
                p3 = ((3)*delta_t)/60;
                figure(11),plot(nonzeros(datafin{ii}(:,1)),nonzeros(datafin{ii}(:,2)),'*','color',C{colSZ},'markersize',15);
                
                ylabel(['mean Nuc/Cyto smad4  ' num2str(p2) ' hours after stimulation']);
                xlabel('mean Nuc/Cyto smad4 Before stimulation');
                legend(['microCol of size ' num2str(colSZ) ]);
                ylim([0 2.5]);
                xlim([0 2.5]);
                hold on
                ampl = nonzeros(datafin{ii}(:,3));
                
                figure(12),plot(colSZ,ampl,'*','color',C{colSZ},'markersize',15);hold on
                
                ylim([0 1.5]);
                xlim([0 coloniestoanalyze+1]);
                ylabel('Amplitude');
                xlabel('microColony size');
                
            end
            
        end

        if flag == 1 && isempty(fr_stim)% if there was no stimulation and looking at pluripotent data
            
            p2 = ((resptime)*delta_t)/60;
            
            figure(11),plot(colSZ,nonzeros(datafin{ii}(:,1)),'*','color',C{colSZ},'markersize',15);hold on% all data
            ylabel('mean Nuc/Cyto smad4 over all imaging time');
            xlabel('microColony size');
            legend(['microCol of size ' num2str(colSZ) ]);
            ylim([0 2.5]);
            xlim([0 coloniestoanalyze+1]);

            
            figure(12),plot(colSZ,nonzeros(datafin{ii}(:,2)),'*','color',C{colSZ},'markersize',15);hold on% over the 'resptime' frames period
            ylim([0 2.5]);
            xlim([0 coloniestoanalyze+1]);
            ylabel(['mean Nuc/Cyto smad4  ' num2str(p2) ' hours into pluri condition']);
            xlabel('microColony size');
            
        end
        
    end
    
 end

end
