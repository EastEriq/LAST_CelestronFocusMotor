        function resp=query(N,dest,cmd,data)
            % Send a command and sit waiting for its reply
            % Dispose of previous traffic potentially having
            % filled the inbuffer, for an immediate response
            flushinput(N.Port)
            % just reading all bytes sometimes is not enough
            %  when the buffer is full since a long time, the expected 
            %  reply gets lost anyway (don't know why)
%             if N.Port.BytesAvailable>0
%                 %disp(['purging buffer with ' num2str(N.Port.BytesAvailable) ' bytes'])
%                 fread(N.Port,N.Port.BytesAvailable);
%             end
            if exist('data','var')
                N.send(dest,cmd,data);
            else
                N.send(dest,cmd);
            end
            resp=N.waitResponse(dest,cmd);
        end
