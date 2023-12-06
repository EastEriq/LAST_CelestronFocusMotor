function HasFocuser=check_for_focuser(F)
% check if there is a focuser by querying its version
            HasFocuser=false;
            try
                resp=F.query(inst.CelDev.FOCU,inst.AUXcmd.GET_VER);
                HasFocuser=resp.good;
                F.LastError='';
            catch ex
                F.LastError=['not able to check for Focus Motor on ' F.Port];
                F.reportException(ex, F.LastError);
                
            end
            
            if HasFocuser
                F.report("a Celestron Focus Motor was found on "+F.Port+'\n')
            else
                F.report("no Celestron Focus Motor found on "+F.Port+'\n')
                F.LastError=['no Celestron Focus Motor found on ' F.Port];                
            end 
