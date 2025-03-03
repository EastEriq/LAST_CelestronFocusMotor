function resp=serialQueryCallback(N)
% callback function, used to perform a noniterruptible serial write
%  followed by a serial read
% The result of the query (controller response, or errors) is stored in
%  N.SerialReply, which is visible in any context

    dest=N.SerialCommand.dest;
    cmd=N.SerialCommand.cmd;
    data=N.SerialCommand.data;
    
    if isa(N.SerialResource,'serial') && strcmp(N.SerialResource.status,'open')
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
    N.SerialReply=resp;
% this is still fragile because there is a race on exit - N.SerialReply
%  could be overwritten
