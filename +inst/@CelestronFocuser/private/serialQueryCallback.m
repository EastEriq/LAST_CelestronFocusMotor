function resp=serialQueryCallback(N,dest,cmd,data)
% callback function, used to perform a noniterruptible serial write
%  followed by a serial read
% The result of the query (controller response, or errors) is stored in
%  N.SerialReply, which is visible in any context
    arguments
        N inst.CelestronFocuser
        dest=N.SerialCommand.dest;
        cmd=N.SerialCommand.cmd;
        data=N.SerialCommand.data;
    end

    % void .SerialReply first
    resp=inst.AUXmsg();
    N.SerialReply=resp;

    if isa(N.SerialResource,'serial') && isvalid(N.SerialResource) && ...
            strcmp(N.SerialResource.status,'open')
        flushinput(N.SerialResource)
        if ~isempty(data)
            N.send(dest,cmd,data);
        else
            N.send(dest,cmd);
        end
        resp=N.waitResponse(dest,cmd);
    else
        % for instance, before the SerialResource is opened
        resp=inst.AUXmsg();
    end
    % use the property only if called without explicit return argument,
    %   i.e. as a timer callback; otherwise it can race with the
    %   non-callback use of it
    if nargout==0
        N.SerialReply=resp;
    end
