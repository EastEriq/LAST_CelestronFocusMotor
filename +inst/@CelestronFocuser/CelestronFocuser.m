classdef CelestronFocuser < obs.focuser
    
    properties (Description='api,must-be-connected, encode_Value, rw')
        Pos double =NaN;
    end
    
    properties (Description='api, type=logical, rw')
        Connected; % untyped, because the setter may receive a logical or a string
    end
    
    properties (GetAccess=public, SetAccess=private)
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
                Description='api,must-be-connected, encode_Value, type=string')
        Status char    = 'unknown';
    end
    
    properties (Hidden=true, GetAccess=public, SetAccess=private, Transient, ...
                Description='api,must-be-connected, encode_Value')
        Limits=[NaN,NaN];
    end
    
    
    methods
        % constructor and destructor
        function F=CelestronFocuser(Locator)
            % Now REQUIRES locator. Think at implications
            if exist('Locator','var')
                if isa(Locator,'obs.api.Locator')
                    id = Locator.Canonical;
                elseif isa(Locator,'char') || isa(Locator,'string')
                    L=obs.api.Locator('Location',Locator);
                    id=L.Canonical;
                else
                    id='';
                end
            else
                id='';
            end
            % call the parent constructor
            F=F@obs.focuser(id);
            % fill initial status of untyped .Connected
            F.Connected=false;
        end

        function delete(F)
            if F.Connected
                F.disconnect;
            end
        end

    end

    methods
        %getters and setters
         %function tf=get.Connected(F)
         %     % FIXME - think at this better later. Perhaps an overkill
         %     tf = strlength(F.Port)>0 && check_for_focuser(F);
         %end

        function set.Connected(F,tf)
            % when called via the API, the argument is received as a string
            if isa(tf,'string')
                tf=eval(tf);
            end
            if isempty(F.Connected)
                F.Connected=false;
            end
            % don't try to connect if already connected, as per API wiki
            if ~F.Connected && tf
                F.Connected=F.connect;
            elseif F.Connected && ~tf
                F.Connected=~F.disconnect;
            end
        end

        function focus=get.Pos(F)
            % former abstractor code had here a check IsConnected, and
            %  attempted to reconnect - I think such remediations should be
            %  left out of the elementary getters
            try
                resp=F.query(inst.CelDev.FOCU, inst.AUXcmd.GET_POSITION);
                focus=resp.numdata;
                F.LastError='';
            catch ex
                focus=NaN;
                F.reportException(ex, 'could not read focuser %s position',F.Id);
                F.Connected=false;
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
                    F.Connected=false;
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
            catch ex
                Limits=[NaN,NaN];
                F.Connected=false;
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
            catch ex
                F.reportException(ex, ['could not get focuser %s status,',...
                                       ' communication problem?'],F.Id);
                F.Connected=false;
            end
        end
        
    end
    
    % prototpes of exported methods, which are defined in separate files

    methods(Description='api,must-be-connected')
        abort(F)
        out = probe(F)
    end
    
    methods (Description='api, type_param1=string, type_param2=double, type_param3=logical, type_param4=integer, type_out=string')
        function out = test_params(Obj, param1, param2, param3, param4)
            out = sprintf("param1='%s', param2=%.2f, param3=%s, param4=%d", param1, param2, string(param3), param4);
        end
    end
    
    methods (Description='api')
        function out = test_exception(Obj)
            throw(MException('OCS:Kaboom', 'Kaboom: You asked for it!'));
        end
    end

end
