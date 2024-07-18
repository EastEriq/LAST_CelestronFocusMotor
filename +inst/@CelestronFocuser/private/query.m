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
                N.SerialCommand=struct('dest',dest,'cmd',cmd,'data',[]);
                if exist('data','var')
                    N.SerialCommand.data=data;
                end
                % Locking mechanism: the monolithic part of the query (serial
                %  write-read) is run in a one shot timer callback function
                %  initiated on purpose. Such calls are uninterruptible and queued,
                %  as well as the instrument callbacks, and thus seem to provide a decent
                %  solution when interactive (code) and messenger callbacks
                %  coexist asynchronously.
                % Using such dummy timers for the purpose may severely
                %  interfere with other timed callbacks used in the same matlab
                %  session, be warned. I suppose that any timer operation involving
                %  communication with the mount will deadlock.
                % I also considered callbacks triggered by notify() on class
                %  events. It turn out that they are interruptible instead,
                %  so that a second callback can interrupt the executing
                %  first between writing and reading the serial port, so they
                %  were not a soultion
                ds=dbstack;
                callchain={ds.name};
                calledFromCallback = any(contains(callchain,{'timercb','instrcb'}));
                
                if calledFromCallback
                    % call directly the monolithic query
                    N.reportDebug('** calling monolithic query, from callback\n');
                    resp=N.serialQueryCallback;
                else
                    % call it via a callback, so that it is uninterruptible.
                    % Using N.SerialCommand and N.SerialReply to exchange data with the
                    %  callback
                    N.reportDebug('** calling monolithic query, from code\n');
                    start(N.SerialCollector); stop(N.SerialCollector);
                    try
                        resp=N.SerialReply;
                    catch SE
                        % comment (old) from the equivalent in
                        %  XerxesMountBinary.binaryQuery
                        % FIXME - we shouldn't get here. We do, sometimes with
                        %  bytes (cmd?) in X.SerialResource.UserData, sometimes
                        %  with "Unrecognized function or variable
                        %  'errormessages'"
                        for j=1:numel(SE.stack)
                            fprintf('%s line %d\n',SE.stack(j).name,SE.stack(j).line)
                        end
                        disp(N.SerialResource.UserData)
                    end
                end
            end
        end
