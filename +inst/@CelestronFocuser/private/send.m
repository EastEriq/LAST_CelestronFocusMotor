        function send(F,dest,cmd,data) % Send Command
            % Stream and send the command, object of class AUXmsg
            % The relevant communication port is supposed to have been
            % opened regularly
            if exist('data','var')
                msg=AUXmsg(CelDev.APPL,dest,cmd,data);
            else
                msg=AUXmsg(CelDev.APPL,dest,cmd);
            end
            % fprintf(' %02X',AUXmsg.stream(msg)); fprintf('\n')
            fprintf(F.serial_resource,char(AUXmsg.stream(msg)));
        end
