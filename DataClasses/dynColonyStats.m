classdef dynColonyStats %object for storing dynamic colony level data
    properties
        ncells %array of dynCell objects
        traces
        stats
    end
    
    methods
%         function obj = dynColonyStats(currcolony) % currently not used
%             
%             ntimes = length(peaks); % number of time points
%             Ntr = size(currcolony.cells,2); % number of trajectories
%             onframesall = zeros(length(peaks),size(currcolony.cells,2));
%             colsz_perframe = zeros(length(peaks),size(currcolony.cells,2));
%             colsz_fin = zeros(length(peaks),1);
%             
%             for j = 1:Ntr
%                 one = (currcolony.cells(j).onframes)';
%                 onframesall(one(1):one(end),j) = one;
%                 
%                 for k = 1:ntimes
%                     colsz_perframe(k,j) = size(nonzeros(onframesall(k,j)),1);
%                     colsz_fin(k) = sum(colsz_perframe(k,:),2);
%                     
%                 end
%                 
%                 
%             end
%             
%             obj.ncells = colsz_fin;
%             
%         end
               
        function obj = dynColonyStats(currcolony)% method to obtain the traces
        
        end
        function % method to obtain statistics before and after bmp4 was added
            
        end
        
        
    end
end       