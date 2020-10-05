        function out=waitResponse(F,dest,cmd)
            % blocking. Sits here till a response matching the desired
            % pattern is found in the input serial stream, and
            % wastes anything else which arrives inbetween
            % note that we check for a response, i.e. invert src<->dest
            out=inst.AUXmsg();
            buf='';
            retries=100;
            i=0; received=false;
            while i<retries && ~received
                if F.SerialResource.BytesAvailable>0
                    buf=[buf,fread(F.SerialResource,...
                           [1,F.SerialResource.BytesAvailable],'char')];
                    % parsing is a bit tricky: we we are good to go if we find in
                    % the input [src dest cmd], if two bytes before that is 0x3B,
                    % and if we have already len+1 other bites of it;
                    % otherwise, we keep growing the input buffer.
                    % Any other 0x3B not followed by the desired sequence, cause
                    % the removal of the trailing message.
                    % Also, cmd may be the command waited for, if legal,
                    %  or UNRECOGNIZED_COMMAND otherwise
                    pstart=regexp(buf,[';.' uint8([dest inst.CelDev.APPL])...
                           '[' uint8([cmd,inst.AUXcmd.UNRECOGNIZED_COMMAND]) ']']);
                    if ~isempty(pstart)
                        pend=pstart+buf(pstart+1)+2;
                        if numel(buf) >= pend
                            out=inst.AUXmsg.check(buf(pstart:pend));
                            received=true;
                        end
                    end
                end              
                if ~received
                    pause(0.05);
                    i=i+1;
                end
            end
        end
