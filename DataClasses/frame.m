classdef frame
    %class to store data from one Cytoo plate
    
    properties
        data %contains colony objects on plate
        microscope % should be 'Andor' or 'MM'
        position % number of position (can be 0)
        time % number of time (can be 0)
        filestruct % file structure
    end
    
    methods
        
        function obj=frame(data,time,position,files,microscope)
            obj.data = data;
            obj.time=time;
            obj.position = position;
            obj.filestruct = files;
            obj.microscope = microscope;
            
        end
        

        
    end
    
end