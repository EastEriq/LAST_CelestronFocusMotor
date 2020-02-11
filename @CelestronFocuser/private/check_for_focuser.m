function HasFocuser=check_for_focuser(F)
% check if there is a focuser by querying its version
            HasFocuser=false;
            try
                resp=F.query(CelDev.FOCU,AUXcmd.GET_VER);
                HasFocuser=resp.good;
            catch
                
            end
            
            if HasFocuser
                F.report("a Celestron Focus Motor was found on "+F.Port+'\n')
            else
                F.report("no Celestron Focus Motor found on "+F.Port+'\n')
            end 
