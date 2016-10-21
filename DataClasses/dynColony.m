classdef dynColony %object for storing dynamic colony level data
    properties
        cells %array of dynCell objects
        ncells % vector containing number of cells, same length as frames
        onframes % frames in which colony exists
        nucfluor % vector of total nuclear intensity over colony   
                 %(reliable even when splitting isn't)
        cytfluor %vector of total nuclear intensity over colony   
                 %(reliable even when splitting isn't)
        ncells_predicted 
        ncells_actual
        
    end
    
    methods
        function obj = dynColony(cells)
            if nargin == 1
            obj.cells = cells;
            elseif nargin == 0
                obj.cells = dynCell();
            end
        end
        
        function obj = addCellToColony(obj,newCell)
            obj.cells(end+1) = newCell;
        end
  
        function ncells = numOfCells(obj,time)
            alltimes = [obj.cells.onframes];
            ncells = sum(alltimes==time);
        end
        
        function plotAllCells(obj)
            figure; hold on;
            cc ={'r.-','g.-','b.-','k.-','m.-','c.-','y.-'};
            for ii = 1:length(obj.cells)
                of = obj.cells(ii).onframes;
                rat1 = obj.cells(ii).ratio1;
                plot(of,rat1',cc{mod(ii,7)+1});
            end
        end
        function smadratio = NucSmadRatio(obj)%all timepoints, traces
             
            Ntr = size(obj.cells,2);
            alltimes = cat(1,obj.cells.onframes);
            timepoints = max(alltimes);
            smadratio = zeros(timepoints,Ntr);
            for k=1:Ntr
                if ~isempty(obj.cells(k).onframes)
            smadratio(obj.cells(k).onframes(1):obj.cells(k).onframes(end),k) = obj.cells(k).fluorData(:,2)./obj.cells(k).fluorData(:,3);
                end
            end
           
        end
        function smadratio = NucSmadRatioOld(obj)% for the data files returned by the older segmentation (3D)
             
            Ntr = size(obj.cells,2);
            alltimes = [obj.cells.onframes];
            timepoints = max(alltimes);
            smadratio = zeros(timepoints,Ntr);
            for k=1:Ntr
                
            smadratio(obj.cells(k).onframes(1):obj.cells(k).onframes(end),k) = obj.cells(k).fluorData(:,2)./obj.cells(k).fluorData(:,3);
           
            end
        end 
        function nuconly = NucOnlyData(obj)%all timepoints, traces
             
            Ntr = size(obj.cells,2);
            alltimes = cat(1,obj.cells.onframes);
            timepoints = max(alltimes);
            nuconly = zeros(timepoints,Ntr);
            for k=1:Ntr
                if ~isempty(obj.cells(k).onframes)
            nuconly(obj.cells(k).onframes(1):obj.cells(k).onframes(end),k) = obj.cells(k).fluorData(:,1);
           end
            end
           
        end
        function dynsmad = DynNucSmadRatio(obj,tpts,fr_stim,resptime,range,jumptime)%
            % tpts = lenth(peaks);
            % jumptime - number of frames needed to respod to stimulation
            if isempty(jumptime)
                jumptime = 4;
            end
            if (resptime+fr_stim+jumptime)>tpts || (range(2) > tpts)
                disp('resptime var is too large')
                resptime = (tpts);
            end
            
            Ntr = size(obj.cells,2);% how many separate trajectories within this colony
            
            timepoints = tpts;
            data_perframe = zeros(timepoints,Ntr);    % for before, after and ampl
            dynsmad = zeros(Ntr,4);
            if ~isempty(fr_stim)
            for k=1:Ntr
                
                one = (obj.cells(k).fluorData(:,2)./obj.cells(k).fluorData(:,3));
                tmp = (obj.cells(k).onframes)';
                data_perframe((tmp(1):tmp(end)),k) = one;
                dynsmad(k,1) = mean(nonzeros(data_perframe(10:fr_stim,k)));% before start from frame 10  for now
                dynsmad(k,2) = mean(nonzeros(data_perframe((fr_stim+jumptime):(resptime),k)));%after
                dynsmad(k,3) = mean(nonzeros(data_perframe(range(1):range(2),k)));
                dynsmad(k,4) = abs(dynsmad(k,1)-mean(nonzeros(data_perframe((fr_stim+jumptime):(range(2)),k))));
            end
            end
            if isempty(fr_stim)
            for k=1:Ntr
                
                one = (obj.cells(k).fluorData(:,2)./obj.cells(k).fluorData(:,3));
                tmp = (obj.cells(k).onframes)';
                data_perframe((tmp(1):tmp(end)),k) = one;
                dynsmad(k,1) = mean(nonzeros(data_perframe(1:end,k)));
                
                
            end
            end
            
        end
    end
end       