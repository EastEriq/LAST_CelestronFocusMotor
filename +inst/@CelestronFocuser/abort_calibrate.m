function abort_calibrate(F)
    try
        F.send(inst.CelDev.FOCU, inst.AUXcmd.HS_CALIBRATION_ENABLE,0);
        F.lastError='';
    catch
        rep='not able to abort calibration!';
        F.report([rep,'\n'])
        F.lastError=rep;
    end
end
