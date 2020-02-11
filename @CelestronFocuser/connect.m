function F=connect(F,Port)
            if ~exist('Port','var') || isempty(Port)
                 for Port=seriallist
                    try
                        % look for one NexStar device on every
                        %  possible serial port. Pity we cannot
                        %  look for a named (i.e. SN) unit
                        F.connect(Port);
                        if check_for_focuser(F)
                            break
                        else
                            delete(instrfind('Port',Port))
                        end
                    catch
                        F.report("no Celestron Focus Motor found on "+Port+'\n')
                    end
                 end
            end
            
            try
                delete(instrfind('Port',Port))
            catch
            end
            
            try
                F.serial_resource=serial(Port);
                % serial has been deprecated in 2019b in favour of
                %  serialport... all communication code should be
                %  transitioned...
            catch
            end
            
            try
                if strcmp(F.serial_resource.status,'closed')
                    fopen(F.serial_resource);
                end
                F.Port=F.serial_resource.Port;
            catch
                F.lastError(['Port ' F.serial_resource.Port ' cannot be opened'])
            end
            set(F.serial_resource,'BaudRate',19200,'Terminator',{'',10},'Timeout',1);
            % (quirk: write terminator has to be 10 so that 10 in output
            %  binary data is sent as such)
        end
