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

    % non-API-demanded properties, Enrico's judgement
    properties (Hidden=true) 
        verbose=true; % for stdin debugging
        serial_resource % the serial object corresponding to Port
    end
    
    properties (Hidden=true, GetAccess=public, SetAccess=private)
        lastError='';
        limits=[NaN,NaN];
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
                F.lastError='';
            catch
                focus=NaN;
                F.lastError='could not read focuser position';
            end
        end
        
        function set.Pos(F,focus)
            if focus<F.limits(1) ||  focus>F.limits(2)
                F.lastError='Focuser commanded to move out of range!';
            else
                try
                    F.LastPos=F.Pos; %this works
                    F.send(CelDev.FOCU,AUXcmd.GOTO_FAST,F.num2bytes(focus,3));
                    F.lastError=''; %this fails
                catch
                    F.lastError='set new focus position failed';
                end
            end
        end
        
        function limits=get.limits(F)
            try
                hexlimits=F.query(CelDev.FOCU,AUXcmd.GET_HS_POSITIONS);
                limits=[F.bytes2num(hexlimits.bindata(1:4)),...
                        F.bytes2num(hexlimits.bindata(5:8))];
            catch
                limits=[NaN,NaN];
            end
        end
        
        function s=get.Status(F)
            % desired would be idle/moving, but there is no firmware call
            %  for that. Moving can be determined by looking at position
            %  changes? What if the focuser is stuck? what if motion has
            %  been aborted?
            s='unknown';
            try
                p1=F.Pos;
                resp=F.query(CelDev.FOCU,AUXcmd.IS_GOTO_OVER);
                reached=(resp.bindata==255);
                pause(0.1)
                if F.Pos~=p1
                    s='moving';
                else
                    s='idle';
                end
            catch
            end
        end
        
    end
    
end
