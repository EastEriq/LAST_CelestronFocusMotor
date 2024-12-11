classdef CelestronFocuser < obs.focuser
    
    properties (SetObservable,GetObservable)
        Pos double =NaN;
    end
    
    properties (GetAccess=public, SetAccess=private)
        FocuserType = 'Celestron Focus Motor'; 
    end
    
    properties (GetAccess=public, SetAccess=private, GetObservable)
        Status char    = 'unknown';
        LastPos double = NaN;
        TargetPos double = NaN;
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
        SerialCommand
        SerialReply
        % Add a timer object for querying the controller with
        %  noninterruptible callbacks
        SerialCollector timer;
    end
    
    properties (Hidden=true, GetAccess=public, SetAccess=private, Transient)
        Limits=[NaN,NaN];
    end

    
    methods
        % constructor and destructor
        function F=CelestronFocuser(id)
            % call the parent constructor
            if nargin==0
                id='';
            end
            F=F@obs.focuser(id);
            % FIXME - this asks if the mirror is locked, and if not the
            %  obs.focuser constructor deletes the object all together,
            %  causing an error in the following line
            F.GitVersion=obs.util.tools.getgitversion(mfilename('fullpath'));
            % do nothing else, connecting to port in a separate method
            % set the callback function here, instead of creating anew the
            %  timer. I have no good solution for deleting the timer when 
            %  clearing the object, so I try to delete it if it is
            %  already in the workspace. It is important to delete, rather
            %  than to recycle, because the timer associated to a destroyed
            %  object will reference an invalid serial resource
            delete(timerfind('Name','FocuserSerialInquirer'));
            F.SerialCollector=timer('Name','FocuserSerialInquirer',...
                        'ExecutionMode','SingleShot','BusyMode','Queue',...
                        'StartDelay',0,'TimerFcn',@(~,~)F.serialQueryCallback);
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
            F.pushPVvalue(focus);
        end
        
        function set.Pos(F,focus)
            if isnan(focus) || isempty(focus)
                F.reportError('invalid focuser position commanded!')
            end
            % empirically, the moving rate seems to be ~300 steps/sec
            if focus<F.Limits(1) || focus>F.Limits(2)
                F.reportError('Focuser %s commanded to move to %d, out of its range [%d,%d]!',...
                                       F.Id,focus,F.Limits);
            else
                try
                    F.pushPVvalue(focus);
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
                % a disconected focuser will report empty Pos
                if ~isempty(p1)
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
                end
            catch
                F.reportError(['could not get focuser %s status,',...
                                       ' communication problem?'],F.Id);
            end
            F.pushPVvalue(s);
        end
        
    end
    
end
