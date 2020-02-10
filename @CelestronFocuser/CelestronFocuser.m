classdef CelestronFocuser <handle
    
    properties
        Pos=NaN;
    end
    
    properties (GetAccess=public, SetAccess=private)
        Status='unknown';
        LastPos=NaN;
    end
    
    properties (Hidden=true)
        Port="";
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

    methods 
        %getters and setters
        function focus=get.Pos(F)
            try
                resp=F.query(CelDev.FOCU,AUXcmd.GET_POSITION);
                focus=resp.numdata;
            catch
                focus=NaN;
            end
        end
        
        function set.Pos(F,focus)
            try
                F.LastPos=F.Pos;
                F.send(CelDev.FOCU,AUXcmd.GOTO_FAST,F.num2bytes(focus,3));
            catch
            end
        end
        
    end
    
end
