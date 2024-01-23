function HasFocuser=probe(F)
% trimmed from check_for_focuser, without messages
% check if there is a focuser by querying its version
    HasFocuser=false;
    try
        resp=F.query(inst.CelDev.FOCU,inst.AUXcmd.GET_VER);
        HasFocuser=resp.good;
    catch
    end