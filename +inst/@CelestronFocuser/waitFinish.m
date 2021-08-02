function Flag = waitFinish(Focuser,timeout)
% wait until the focuser ends moving and returns to idle,
%  with a timeout in case it gets stuck or offline
    if ~exist('timeout','var')
        try
            % if the focuser is unreachable, the following would
            %  either error or write a LastError?
            if ~isnan(F.TargetPos) || isempty(F.TargetPos)
                timeout=abs(F.Pos-F.TargetPos)/400; % ~ 400 steps/sec
            else
                timeout=10;
            end
            if ~isempty(F.LastError)
                timeout=10;
            end
        catch
            timeout=20; % seconds (that could be much or too little, depends
                        %  on what the focuser is commanded to do)
        end
    end

    Flag = false;
    t0=now;
    while strcmp(Focuser.Status,'moving') && (now-t0)*24*3600<timeout
        pause(1);
        Focuser.report('.')
    end
    pause(0.5);
    if (strcmp(Focuser.Status, 'idle'))
        Focuser.report(sprintf('\nFocuser %s movement completed\n',Focuser.Id))
        Flag = true;
    else
        Focuser.reportError(sprintf('A problem has occurred with the focuser. Status: %s\n',...
            Focuser.Status))
    end
end
