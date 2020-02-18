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
    try
        stage=-1;
        start_t=now; t=0;
        F.send(CelDev.FOCU,AUXcmd.HS_CALIBRATION_ENABLE,1);
        % polling till completed:
        while (stage~=256) && t < timeout
            pause(1)
            t=(now-start_t)*3600*24;
            resp=F.query(CelDev.FOCU,AUXcmd.IS_HS_CALIBRATED);
            if resp.good
                stage=resp.numdata;
            end
            F.report(sprintf('... t=%.1f, calibration stage %d, f=%d\n',t,stage,F.Pos))
        end
        if stage==256
            F.report('Calibration completed!\n')
            F.lastError='';
        else
            F.report('Calibration timed out!\n')
            F.lastError='Calibration timed out!';
        end
    catch
        rep=sprintf('Calibration failed at stage %d after %fsec',stage,t);
        F.report([rep,'\n'])
        F.lastError=rep;
    end
end
