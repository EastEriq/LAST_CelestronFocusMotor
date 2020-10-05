function avail=isPortAvailable(F)
% Check if the serial resource assigned to the focuser object is
%  still known to the system, and delete if it disappeared.
% This is often necessary as virtual serial ports, assigned to
%  serial-USB devices frequently disconnect and reconnect under
%  another name, due to EMI, poor cables and whatnot.
   
    portlist=serialportlist; % use seriallist in rev<2019 instead
    
    avail=any(contains(portlist,F.Port));
    if ~avail
        F.report("Serial "+F.Port+' disappeared from system, closing it\n')
        try
            delete(instrfind('Port',F.Port))
        catch
            F.LastError=['cannot delete Port object ' F.Port ' -maybe OS disconnected it?'];
        end
    end
