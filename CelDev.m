classdef CelDev < uint8
    % information collated from various online sources, Derik's info
    %  and direct inspection on our CGX/L
    % cfr also https://github.com/indilib/indi/blob/master/drivers/focuser/celestronauxpacket.h
    enumeration
        ANY_ (0)
        MAIN (1)
        OLHC (4)  % Hand Control as in Andre' Paquette doc
        HAND (13) % apparently, on the CGX=L / NexStar+
        AZIM (16)
        ALTI (17)
        FOCU (18)
        APPL (32)
        NEXR (34)  % NEX_REMOTE
        % AZIM exchanges messages with a device 48, ALTI with 49
        AZsw (48)
        ALsw (49)
        GPSU (176)
        RTC_ (178) % CGE only
        % the presence of a device 180 is checked for by INDI
        WIFI (181)
        BATT (182)
        CHRG (183)
        LGHT (191)
    end
end