function HasFocuser=check_for_focuser(F)
% check if there is a focuser by querying its motion limits
            try
                hexlimits=F.query(CelDev.FOCU,AUXcmd.GET_HS_POSITIONS);
                FocuserLimits=[F.bytes2num(hexlimits.bindata(1:4)),...
                                 F.bytes2num(hexlimits.bindata(5:8))];
                HasFocuser=true;
            catch
                HasFocuser=false;
            end 
