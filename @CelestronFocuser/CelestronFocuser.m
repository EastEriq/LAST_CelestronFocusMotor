classdef CelestronFocuser <handle
    
    properties
        Status='unknown';
        Pos=NaN;
        LastPos=NaN;
    end
    
    properties (Hidden=true)
        Port="";
    end

    properties(Hidden, Constant)
        %master=CelDev.APPL
    end

    properties (Hidden=true) % non-API, Enrico's judgement
        verbose=true; % for stdin debugging
        serial_resource % the serial object corresponding to Port
    end

    
    methods
        % constructor and destructor
        function F=CelestronFocuser()
            % does nothing, connecting to port in a separate method
        end
        
        function delete(F)
            delete(F.serial_resource)
            % shall we try-catch and report success/failure?
        end

    end
    
end
