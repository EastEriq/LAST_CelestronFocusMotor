function abort(F)
% stops the focuser movement
    try
        F.send(CelDev.FOCU,AUXcmd.MOVE_POS,0)
        F.lastError='';
    catch
        F.lastError='could not abort motion, communication problem?';
    end
end
