function connected=connect(F)
% connect to a focus motor on the specified Port. Port can be the name of a
% serial resource (e.g. '/dev/ttyACM0') or a physical PCI address
% (e.g 'pci-0000:00:14.0-usb-0:8:1.0')
% All serial ports are tested if Port is omitted.

% PhysicalAddress is a property of the superclass obs.focuser
    if isempty(F.PhysicalAddress)
        for Port=seriallist
            try
                % look for one NexStar device on every
                %  possible serial port. Pity we cannot
                %  look for a named (i.e. SN) unit
                F.PhysicalAddress=Port;
                F.connect();
                if isempty(F.LastError)
                    F.Connected=true; % calls F.connect again, too bad
                    return
                else
                    delete(instrfind('Port',Port))
                    F.PhysicalAddress=[];
                end
            catch
                F.report(['no Celestron Focus Motor found on ' char(Port) '\n'])
            end
        end
        return
    else
        if isPCIusb(string(F.PhysicalAddress))
            Port=idpath_to_port(F.PhysicalAddress);
        else
            Port=F.PhysicalAddress;
        end
    end
        
    try
        delete(instrfind('Port',Port))
    catch
        F.reportError(['cannot delete Celestron Focus Motor Port object ' Port ' -maybe OS disconnected it?']);
    end

    try
        F.SerialResource=serial(Port);
        % serial has been deprecated in 2019b in favour of
        %  serialport... all communication code should be
        %  transitioned...
    catch
        F.reportError(['cannot create Port object ' Port ' for Celestron Focus Motor']);
    end

    try
        if strcmp(F.SerialResource.status,'closed')
            % now, the next fopen causes a warning like
            %  RXTX fhs_lock() Error: opening lock file: /var/lock/LCK..ttyACM0: File exists
            %  to be written on stderr, for every OTHER serial port of the
            %  system which is already in use, i.e. not for the specific
            %  port we are opening. Probably it is a bug of serial,
            %  which might be resolved by serialport. Anyway, innocuous
            fopen(F.SerialResource);
            set(F.SerialResource,'BaudRate',19200,'Terminator',{'',10},'Timeout',1);
            % (quirk: write terminator has to be 10 so that 10 in output
            %  binary data is sent as such)
        end
        F.Port=F.SerialResource.Port;
        if check_for_focuser(F)
            F.PhysicalId=F.PhysicalAddress;
            connected=true;
        end
    catch
        F.reportError(['Port "' char(Port) '" for Celestron Focus Motor cannot be opened']);
        delete(instrfind('Port',Port)) % (catch also error here?)
    end
end
