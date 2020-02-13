function calibrate(F)
% run the calibration routine to find the movement limits.
% Beware, the process takes a few minutes
% Note: calibration needs that the focused is powered by a really good
%  power supply, USB powering is not sufficient, the focuser may still move
%  a bit slower, but the serial resource will continuously disconnect,
%  and cause a mess because of resources left open and new USB enumerations
%  created.
% Or to say it better: doesnt't matter, take for granted that the focuser
% will disconnect itself, just reconnect it after a few minutes
    timeout=240;
    try
        stage=-1;
        start_t=now;
        F.send(CelDev.FOCU,AUXcmd.HS_CALIBRATION_ENABLE,1);
        % polling till completed:
        while (stage~=256) && (now-start_t)*3600*24 < timeout
            pause(1)
            resp=F.query(CelDev.FOCU,AUXcmd.IS_HS_CALIBRATED);
            if resp.good
                stage=resp.numdata;
            end
            F.report(['...calibration stage ',num2str(stage),'\n'])
        end
        if stage==256
            F.report('Calibration completed!\n')
            F.lastError='';
        else
            F.report('Calibration timed out!\n')
            F.lastError='Calibration timed out!';
        end
    catch
        rep=sprintf('Calibration failed at stage %d after %fsec',stage,...
            (now-start_t)*3600*24);
        F.report([rep,'\n'])
        F.lastError=rep;
    end
end
