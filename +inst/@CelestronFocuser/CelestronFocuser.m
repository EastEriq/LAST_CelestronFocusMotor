classdef CelestronFocuser < LAST_Handle
    
    properties
        Pos=NaN;
    end
    
    properties (GetAccess=public, SetAccess=private)
        Status='unknown';
        LastPos=NaN;
        FocType = 'Celestron Focus Motor'; 
    end
        
    properties (SetAccess=public, GetAccess=private)
        relPos=NaN;
    end
        
    properties (Hidden=true)
        Port="";
    end

    % non-API-demanded properties, Enrico's judgement
    properties (Hidden=true) 
        SerialResource % the serial object corresponding to Port
    end
    
    properties (Hidden=true, GetAccess=public, SetAccess=private, Transient)
        Limits=[NaN,NaN];
    end

    
    methods
        % constructor and destructor
        function F=CelestronFocuser()
            % does nothing, connecting to port in a separate method
        end
        
        function delete(F)
            delete(F.SerialResource)
            % shall we try-catch and report success/failure?
        end

    end

    methods 
        %getters and setters
        function focus=get.Pos(F)
            try
                resp=F.query(inst.CelDev.FOCU, inst.AUXcmd.GET_POSITION);
                focus=resp.numdata;
                F.LastError='';
            catch
                focus=NaN;
                F.LastError='could not read focuser position';
            end
        end
        
        function set.Pos(F,focus)
            % empirically, the moving rate seems to be ~300 steps/sec
            if focus<F.Limits(1) ||  focus>F.Limits(2)
                F.LastError='Focuser commanded to move out of range!';
            else
                try
                    F.LastPos=F.Pos; %this works
                    F.query(inst.CelDev.FOCU, inst.AUXcmd.GOTO_FAST, F.num2bytes(focus,3));
                    F.LastError=''; %this fails
                catch
                    F.LastError='set new focus position failed';
                end
            end
        end
        
        function set.relPos(F,incr)
            p=F.Pos;
            F.Pos=p+incr;
             % (don't use F.Pos=F.Pos+incr, it will fail, likely for access
             %  issues)
        end
        
        function Limits=get.Limits(F)
            try
                hexlimits=F.query(inst.CelDev.FOCU, inst.AUXcmd.GET_HS_POSITIONS);
                Limits=[F.bytes2num(hexlimits.bindata(1:4)),...
                        F.bytes2num(hexlimits.bindata(5:8))];
            catch
                Limits=[NaN,NaN];
            end
        end
        
        function s=get.Status(F)
            % desired would be idle/moving, but there is no firmware call
            %  for that. Moving can be determined by looking at position
            %  changes? What if the focuser is stuck? what if motion has
            %  been aborted?
            % Note - the focuser response can be erratic, maybe because of
            %  poor cables, more likely because of EMI or poor engineering
            %  of the USB/serial communication module 
            %  - I've seen the focuser start moving several
            %  seconds after commanded, i.e. - this complicates guessing the
            %  status
            s='unknown';
            try
                p1=F.Pos;
                resp=F.query(inst.CelDev.FOCU, inst.AUXcmd.IS_GOTO_OVER);
                reached=(resp.bindata==255);
                pause(0.1)
                if F.Pos~=p1
                    s='moving';
                else
                    if reached
                        s='idle';
                    else
                        s='stuck';
                    end
                end
            catch
                F.LastError='could not get status, communication problem?';
            end
        end
        
    end
    
end
