classdef dynCell %object to store dynamic data for a single cell
    
    properties
        
        position % ntimes x 2 vector contain cell positions
        nucArea % area of nucleus
        fluorData %fluorescence data (nuc column 1st, follow by nuc and cytoplasmic data for each column)
        onframes % frames of movie that cell is present in (starts from 1)
        daughters % cell number of daughter cells
        mother % number of mother cell
        dead % flag to mark if cell died at the end of trajcetory
        
    end
    
    methods
        function obj = dynCell(celldata,onframes) %constructor function
            
            
            if nargin == 0
                obj.position=[];
                obj.nucArea = [];
                obj.fluorData = [];
                obj.onframes =[];
                return;
            end
            
            if isstruct(celldata) %this can work in 3d.
                obj.position = celldata.Centroid;
                obj.nucArea = celldata.Area;
                obj.fluorData = celldata.fluordata;
            else
                
                obj.position = celldata(:,1:2);
                obj.nucArea = celldata(:,3);
                obj.fluorData = celldata(:,5:end);
                
            end
            if ~exist('onframes','var')
                obj.onframes=1:size(celldata,1);
            else
                obj.onframes = onframes;
            end
            obj.daughters = [];
            obj.mother =[];
            obj.dead = 0;
        end
        
        
        function nT=numberOfTimePoints(obj) %number of time points cell was alive for
            nT = length(obj.onframes);
        end
        
        function dat = data(obj) % dump cell data in the usual format
            dat = [obj.position obj.nucArea -1*ones(obj.numberOfTimePoints,1) obj.fluorData];
        end
        
        function obj = addTimeToCell(obj,dat,newframes) %add more time points to a cell's trajectory
            if isstruct(dat)
                obj.position = [obj.position; dat.Centroid];
                obj.nucArea = [obj.nucArea dat.Area];
                obj.fluorData = [obj.fluorData; dat.fluordata];
            else
                
                obj.position = [obj.position; dat(:,1:2)];
                obj.nucArea = [obj.nucArea; dat(:,3)];
                obj.fluorData = [obj.fluorData; dat(:,5:end)];
            end
            obj.onframes = [obj.onframes; newframes];
        end
        
        function nF = numberOfFluorChannels(obj) %number of fluorescent channels of data (besides nuclear channel)
            nF = (size(obj.fluorData,2)-1)/2;
        end
        
        function rat1 = ratio1(obj)
            rat1 = obj.fluorData(:,2); %./obj.fluorData(:,3);
        end
    end
end