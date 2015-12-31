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
    end
end       