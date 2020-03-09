classdef AUXmsg < handle
    properties
        time
        len=0
        src
        dest
        cmd
        bindata
        numdata
        chksum
        chkok=false
        good=false
    end
        
    methods %dummy constructor
        function msg=AUXmsg(src,dest,cmd,data)
            if exist('src','var')
                msg.src=inst.CelDev(src);
                msg.len=1;
            end
            if exist('dest','var')
                msg.dest=inst.CelDev(dest);
                msg.len=2;
            end
            if exist('cmd','var')
                msg.cmd=inst.AUXcmd(cmd);
                msg.len=3;
            end
            if exist('data','var')
                msg.bindata=data;
                msg.len=3+numel(msg.bindata);
            end
            msg.chksum=msg.checksum(msg.stream(msg));
        end
                
    end
    
    methods(Static)

        function packet=stream(msg)
            % flatten an AUXmsg object into a byte stream
            packet=[59 msg.len uint8([msg.src msg.dest]) uint8(msg.cmd) ...
                       uint8(msg.bindata), 0];
            packet(end)=msg.checksum(packet);
        end
        
        function msg=check(packet)
            % check a byte string and assess if it is a proper AUX msg
            packet=uint8(packet);
            % an AUX packet should start with 59, contain the number of
            %  bytes specified, and end with the proper checksum
            %  But what if 59 is also part of the data?           
            msg=inst.AUXmsg;            
            msg.time=now;
            msg.good=packet(1)==59;
            if msg.good
                msg.len=packet(2);
                if length(packet)>=5 && ...
                     (msg.len==length(packet)-3) % excluding 59, len, checksum
                    msg.src=packet(3);
                    msg.dest=packet(4);
                    msg.cmd=packet(5);
                    if msg.len>3
                        msg.bindata=packet(6:(msg.len+2));
                        try
                            msg.numdata=double(msg.bindata)*...
                                (2.^((length(msg.bindata)-1)*8:-8:0))';
                        catch
                            % place a breakpoint here for debugging...
                            disp(msg.bindata)
                        end
                    end
                    msg.chksum=packet(end);
                    msg.chkok= msg.chksum==msg.checksum(packet);
                    % flag answers to illegal commands as bad messages 
                    if msg.cmd==inst.AUXcmd.UNRECOGNIZED_COMMAND
                        msg.good=false;
                    end
                    % msg.good= msg.good & msg.chkok;
                else
                    msg.good=false;
                    msg.bindata=packet(3:msg.len+2);
                end
            end      
        end

        function hex=checksum(packet)
            % compute the checksum byte of a flattened AUXmsg
            hex=uint8(256-mod(sum(uint8(packet(2:end-1))),256));
        end
        
        function formatted=format(msg)
            % pretty-print an AUXmsg object
            % mnemos are from inst.CelDev and inst.AUXcmd enumerators
            try
                srcname=string(inst.CelDev(msg.src));
            catch
                srcname=['B_' num2str(msg.src)];
            end
            
            try
                destname=string(inst.CelDev(msg.dest));
            catch
                destname=['B_' num2str(msg.dest)];
            end

            try
                cmdname=string(inst.AUXcmd(msg.cmd));
            catch
                cmdname=['CMD_' num2str(msg.cmd)];
            end
                
            formatted=[datestr(msg.time,'HH:MM:SS.FFF')...
                '; #' num2str(msg.len),...
                sprintf(' %4s-->%4s %21s:',srcname,destname,cmdname)];
            if msg.good
                if ~isempty(msg.bindata)
                    % for space, assuming up to 3 bytes
                    formatted=[formatted,' x' sprintf('%02X ',msg.bindata)];
                    formatted=[formatted,...
                        repmat(' ',1,9-3*numel(msg.bindata))];
                    formatted=[formatted,sprintf('(%8d)',msg.numdata)];
                else
                    formatted=[formatted,' ',repmat('.',1,20)];
                end
                if msg.chkok
                    formatted=[formatted sprintf(' [x%02X ok]',msg.chksum)];
                else
                    formatted=[formatted sprintf(' [x%02X !!]',msg.chksum)];
                end
            else
                formatted=[formatted,' !!!' sprintf(' x%02X',msg.bindata)];
            end
        end

    end
    
end