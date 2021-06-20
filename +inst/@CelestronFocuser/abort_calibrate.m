function abort_calibrate(F)
    try
        F.send(inst.CelDev.FOCU, inst.AUXcmd.HS_CALIBRATION_ENABLE,0);
        F.LastError='';
    catch
        F.reportError('not able to abort calibration!')
    end
end
