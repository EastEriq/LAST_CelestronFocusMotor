        function send(F,dest,cmd,data) % Send Command
            % Stream and send the command, object of class inst.AUXmsg
            % The relevant communication port is supposed to have been
            % opened regularly
            if exist('data','var')
                msg=inst.AUXmsg(inst.CelDev.APPL,dest,cmd,data);
            else
                msg=inst.AUXmsg(inst.CelDev.APPL,dest,cmd);
            end
            % fprintf(' %02X',inst.AUXmsg.stream(msg)); fprintf('\n')
            fprintf(F.SerialResource,char(inst.AUXmsg.stream(msg)));
        end
