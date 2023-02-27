classdef CelestronFocuser < obs.focuser
    
    properties (Description='api,must-be-connected')
        Pos double =NaN;
    end
    
    properties (Description='api')
        Connected logical = false;
    end
    
    properties (GetAccess=public, SetAccess=private)
        Status char    = 'unknown';
        LastPos double = NaN;
        TargetPos double = NaN;
        FocuserType = 'Celestron Focus Motor'; 
    end
        
    properties (SetAccess=public, GetAccess=private)
        RelPos=NaN;
    end
        
    properties (Hidden=true)
        Port="";
    end

    % non-API-demanded properties, Enrico's judgement
    properties (Hidden=true) 
        SerialResource % the serial object corresponding to Port
    end
    
    properties (Hidden=true, GetAccess=public, SetAccess=private, Transient, ...
                Description='api,must-be-connected')
        Limits=[NaN,NaN];
    end

    
    methods
        % constructor and destructor
        function F=CelestronFocuser(Locator)
            % Now REQUIRES locator. Think at implications
            %
            % Arie:
            %  The Locator structure contains the break-up of the Location
            %  string into fields.  You can use the separate fields to
            %  compose the path to the respective config file.
            %
            %   Locator with properties:
            % 
            %     CanonicalLocation: "LAST.1.mount11.focuser1"
            %             ProjectName: "LAST"
            %                      NodeId: 1
            %                     MountId: 11
            %                 MountSide: "e"
            %                 EquipType: Focuser
            %                      EquipId: 1
            %                   EquipPos: "NE"
            %                      Project: [1×1 obs.api.Project]
            %                 Hostname: "last11e"
            %                 IpAddress: "127.0.0.1"
            %            ForceRemote: 0
            %                   IsRemote: 0
            %                       IsLocal: 1
            %                DriverClass: "inst.CelestronFocuser"
            %

            id = Locator.CanonicalLocation;
            % call the parent constructor
            F=F@obs.focuser(id);
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
            % former abstractor code had here a check IsConnected, and
            %  attempted to reconnect - I think such remediations should be
            %  left out of the elementary getters
            try
                resp=F.query(inst.CelDev.FOCU, inst.AUXcmd.GET_POSITION);
                focus=resp.numdata;
                F.LastError='';
            catch
                focus=NaN;
                F.reportError('could not read focuser %s position',F.Id);
            end
        end
        
        function set.Pos(F,focus)
            % empirically, the moving rate seems to be ~300 steps/sec
            if focus<F.Limits(1) || focus>F.Limits(2)
                F.reportError('Focuser %s commanded to move to %d, out of its range [%d,%d]!',...
                                       F.Id,focus,F.Limits);
            else
                try
                    F.LastPos=F.Pos; %this works
                    F.query(inst.CelDev.FOCU, inst.AUXcmd.GOTO_FAST, F.num2bytes(focus,3));
                    F.LastError=''; %this fails
                    F.TargetPos=focus;
                catch
                    F.reportError('set focus to %d for focuser %s failed',...
                                          focus, F.Id);
                end
            end
        end
        
        function set.RelPos(F,incr)
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
                F.reportError(['could not get focuser %s status,',...
                                       ' communication problem?'],F.Id);
            end
        end
        
    end
    
    % prototpes of exported methods, which are defined in separate files
    methods(Description='api')
        connect(F,Port)
    end

    methods(Description='api,must-be-connected')
        disconnect(F)
        abort(F)
    end

end
