        function resp=query(N,dest,cmd,data)
            % Send a command and sit waiting for its reply
            
            % check if the serial port is still reachable first.
            % Disconnections are so frequent
            % (consider whether it is worth to protect this way also
            %  send() and waitResponse())
            if ~isPortAvailable(N)
                % ask David which kind of error reporting we expect at
                %  abstraction level: error, F.LastError, stdout, what?
                error(['Port ' N.Port 'disappeared'])
            else
                % Locking mechanism: check the timestamp stored in
                %  X.SerialResource.UserData. If empty, we're clear to go. If it
                %  contains a numeric timestamp, check if it is more than 100msec old
                %  (having ascertained that the typical turnover time for a query
                %  is ~30?ms) to infer that it was left stale by mistake, then also
                %  go. If it is a recent timestamp, give up. This mechanism is
                %  mainly intended so that callback queries don't disrupt main
                %  execution thread ones. If we are lucky, the query asked by the
                %  callback will be retried.
                if ~isempty(N.SerialResource.UserData) && ...
                        (now - N.SerialResource.UserData)*86400 < 0.1
                    N.report('serial query in progress on another thread, giving up\n')
                    % Dispose of previous traffic potentially having
                    % filled the inbuffer, for an immediate response
                else
                    N.SerialResource.UserData=now;
                    flushinput(N.SerialResource)
                    % just reading all bytes sometimes is not enough
                    %  when the buffer is full since a long time, the expected
                    %  reply gets lost anyway (don't know why)
                    %  if N.Port.BytesAvailable>0
                    %      %disp(['purging buffer with ' num2str(N.Port.BytesAvailable) ' bytes'])
                    %                 fread(N.Port,N.Port.BytesAvailable);
                    %  end
                    if exist('data','var')
                        N.send(dest,cmd,data);
                    else
                        N.send(dest,cmd);
                    end
                    resp=N.waitResponse(dest,cmd);
                    N.SerialResource.UserData=[];
                end
            end
        end
