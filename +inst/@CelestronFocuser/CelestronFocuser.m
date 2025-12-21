classdef CelestronFocuser < obs.focuser
    
    properties (SetObservable,GetObservable)
        Pos double = NaN;
        SlowMotion logical = false;
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
        OwnBacklash double = [NaN,NaN]; % not sure they have an effect; don't use
        TargetTolerance = 10; % off-target ticks which we silently tolerate
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
            timername=[class(F) '.FocuserSerialInquirer.' F.Id];
            delete(timerfind('Name',timername));
            F.SerialCollector=timer('Name',timername,...
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
            if isempty(focus) || isnan(focus)
                F.reportError('invalid focuser position commanded!')
                return
            end
            % empirically, the moving rate seems to be ~300 steps/sec
            if focus<F.Limits(1) || focus>F.Limits(2)
                F.reportError('Focuser %s commanded to move to %.0f, out of its range [%d,%d]!',...
                                       F.Id,focus,F.Limits);
            else
                try
                    focus=round(focus);
                    F.pushPVvalue(focus);
                    F.LastPos=F.Pos; %this works
                    if F.SlowMotion
                        F.query(inst.CelDev.FOCU, inst.AUXcmd.GOTO_SLOW, F.num2bytes(focus,3));
                    else
                        F.query(inst.CelDev.FOCU, inst.AUXcmd.GOTO_FAST, F.num2bytes(focus,3));
                    end
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
        
        function set.OwnBacklash(F,b)
            % according to doc, b=0-:-99
            % dubious what it does
            if numel(b)==1
                b=[b,b];
            end
            bn=abs(b(1));
            bp=abs(b(2));
            F.query(inst.CelDev.FOCU, inst.AUXcmd.SET_NEG_BACKLASH, bn);
            F.query(inst.CelDev.FOCU, inst.AUXcmd.SET_POS_BACKLASH, bp);
        end
        
        function b=get.OwnBacklash(F)
            try
                bn=F.query(inst.CelDev.FOCU, inst.AUXcmd.GET_NEG_BACKLASH);
                bp=F.query(inst.CelDev.FOCU, inst.AUXcmd.GET_POS_BACKLASH);
                b=[-bn.numdata,bp.numdata];
            catch
                b=[NaN,NaN];
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
                reached=F.reachedTarget; % ask first, to avoid decisions on old Pos
                p1=F.Pos; % ask it even if we may not need it, so it is pushed
                % a disconected focuser will report empty Pos
                if reached
                    s='idle';
                    t=F.TargetPos;
                    if ~isempty(t) && ~isnan(t) && abs(t-p1)>F.TargetTolerance
                        % check a second time, to make really sure that we
                        %  were not almost there and reached was flagged too
                        %  early
                        pause(0.1)
                        if F.reachedTarget && abs(t-F.Pos)>F.TargetTolerance
                            F.reportError('focuser is idle at %d, but target is %d',...
                                p1,t)
                        end
                    end
                else
                    if ~isempty(p1)
                        pause(0.2)
                        p2=F.Pos;
                        if p2~=p1
                            s='moving';
                        else
                            % check once more, to avoid false reports while
                            %  stopping
                            if F.reachedTarget
                                s='idle';
                            else
                                s='stuck';
                                F.reportError('focuser %s stuck: p1=%d, p2=%d',...
                                               F.Id,p1,p2)
                            end
                        end
                    end
                end
            catch
                F.reportError(['could not get focuser %s status,',...
                                       ' communication problem?'],F.Id);
                s='unknown';
            end
            F.pushPVvalue(s);
        end
        
    end
    
end
