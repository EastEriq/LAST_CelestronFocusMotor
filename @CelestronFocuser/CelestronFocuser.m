classdef CelestronFocuser <handle
    
    properties
        Status="unknown";
        Log="";
        Pos=NaN;
        LastPos=NaN;
    end
    
    properties (Hidden=true)
        Port
        FocuserName="";
        GeoName="";
    end
    
    properties (Hidden=true) % non-API, Enrico's judgement
        verbose=true; % for stdin debugging
    end

    
    methods
        % constructor and destructor
        function F=CelestronFocuser()
            % does nothing, connecting to port in a separate method
        end
    end
    
end
