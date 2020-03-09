function HasFocuser=check_for_focuser(F)
% check if there is a focuser by querying its version
            HasFocuser=false;
            try
                resp=F.query(inst.CelDev.FOCU,inst.AUXcmd.GET_VER);
                HasFocuser=resp.good;
                F.lastError='';
            catch
                F.lastError=['not able to check for Focus Motor on ' F.Port];                
            end
            
            if HasFocuser
                F.report("a Celestron Focus Motor was found on "+F.Port+'\n')
            else
                F.report("no Celestron Focus Motor found on "+F.Port+'\n')
                F.lastError=['no Celestron Focus Motor found on ' F.Port];                
            end 
