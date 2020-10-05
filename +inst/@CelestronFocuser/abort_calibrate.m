function abort_calibrate(F)
    try
        F.send(inst.CelDev.FOCU, inst.AUXcmd.HS_CALIBRATION_ENABLE,0);
        F.LastError='';
    catch
        rep='not able to abort calibration!';
        F.report([rep,'\n'])
        F.LastError=rep;
    end
end
