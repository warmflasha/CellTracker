classdef dynColony %object for storing dynamic colony level data
    properties
        cells %array of dynCell objects
        
    end
    
    methods
        function obj = dynColony(cells)
            obj.cells = cells;
        end
        
        function obj = addCellToColony(obj,newCell)
            obj.cells(end+1) = newCell;
        end
  
        function ncells = numOfCells(obj,time)
            alltimes = [obj.cells.onframes];
            ncells = sum(alltimes==time);
        end
        function smadratio = NucSmadRatio(obj,tr)%all timepoints, traces
             
            Ntr = size(obj.cells,2);
            alltimes = [obj.cells.onframes];
            timepoints = max(alltimes);
            smadratio = zeros(timepoints,Ntr);
            for k=1:Ntr
                
            smadratio(obj.cells(k).onframes(1):obj.cells(k).onframes(end),k) = obj.cells(k).fluorData(:,2)./obj.cells(k).fluorData(:,3);
           
            end
           
        end
        function nuconly = NucOnlyData(obj,tr)%all timepoints, traces
             
            Ntr = size(obj.cells,2);
            alltimes = [obj.cells.onframes];
            timepoints = max(alltimes);
            nuconly = zeros(timepoints,Ntr);
            for k=1:Ntr
                
            nuconly(obj.cells(k).onframes(1):obj.cells(k).onframes(end),k) = obj.cells(k).fluorData(:,1);
           
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