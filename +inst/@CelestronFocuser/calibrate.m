function calibrate(F)
% Run the calibration routine to find the movement limits.
% Beware, the process takes a few minutes, like 3-4.
% With less than perfect USB connection, this causes an almost certain disconnection
%  within a few seconds. A pita. The stale serial resource needs to be
%  deleted, and a new connection has to be estabilished on probably a new
% assigned USB resource.
% Or to say it better: doesnt't matter, take for granted that the focuser
% will disconnect itself, just reconnect it after a few minutes.
    timeout=240;
    stuckreadings=4;
    lastpos=nan(1,stuckreadings);
    try
        stage=-1;
        start_t=now; t=0;
        F.send(inst.CelDev.FOCU,inst.AUXcmd.HS_CALIBRATION_ENABLE,1);
        % polling till completed:
        while (stage~=256) && t < timeout
            pause(1)
            t=(now-start_t)*3600*24;
            resp=F.query(inst.CelDev.FOCU,inst.AUXcmd.IS_HS_CALIBRATED);
            if resp.good
                stage=resp.numdata;
            end
            lastpos(1:end-1)=lastpos(2:end);
            lastpos(end)=F.Pos;
            F.report(sprintf('... t=%.1f, calibration stage %d, f=%d\n',t,stage,lastpos(end)))
            if all(lastpos==lastpos(end))
                F.report('Focuser stuck!')
                F.LastError='Focuser stuck during calibration!';
                break
            end
        end
        if stage==256
            F.report('Calibration completed!\n')
            F.LastError='';
        else
            F.report('Calibration timed out!\n')
            F.LastError='Calibration timed out!';
        end
    catch
        rep=sprintf('Calibration failed at stage %d after %fsec',stage,t);
        F.report([rep,'\n'])
        F.LastError=rep;
    end
end
