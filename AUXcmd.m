classdef AUXcmd < uint8
    % Motor board commands; other boards may have different ones for the
    %  same cmd code
    % compilation started from Andre' Paquette AUX command set,
    %  integrated with motor_commands.h received from Celestron
    enumeration
        GET_POSITION (01)         % return 24 bit position
                                  % Board_48 Board_49 apparently return
                                  %  only two bytes, the first of which may be
                                  %  a flag for switch exceeded (should
                                  %  that be command 08?)
        GOTO_FAST    (02)         % send 24 bit target
        SET_POSITION (04)
        GET_MODEL   (05)
        SET_POS_GUIDERATE (06)    % use the 2 byte CelestronTrackRates to set the rate
        SET_NEG_GUIDERATE (07)    % for Southern hemisphere, track mode EQ_S
                                     % follow by 16/24 bit speed [sidereal/1024] + track rate,
                                     %  or ... [0xFFFD,0xFFFF] are special
        REMOTE_SWITCH_ALIVE (08) % sent periodically by (remote) sensor boards
        SWITCH_STATE_CHANGE (09) % sent by the remote switchings whenever a state change is registered
        AG_STATE_CHANGE  (10) % sent by a remote autoguider to indicate a desired motion
        LEVEL_START  (11)         % move to switch position, ALT only
        PEC_RECORD_START (12)  % Azm only, EQNorth/South must be on before sending this command
        PEC_PLAYBACK (13)
        GET_PEC_BIN (14)
        SET_POS_BACKLASH (16) % backlash, followed by 1 byte (0-99)
        SET_NEG_BACKLASH (17)
        IS_MVSWITCH_OVER   (18)      % (i.e. LEVEL_DONE) return (FF when move finished)
        LEVEL_DONE      (18)      % (i.e. LEVEL_DONE) return (FF when move finished)
        IS_GOTO_OVER    (19)         % return (FF when move finished)
        PEC_STATE_CHANGE (20) % send by a remote pec sensor when a change of state occurs
        PEC_RECORD_DONE (21)
        PEC_RECORD_STOP (22)
        GOTO_SLOW  (23)
        AT_INDEX   (24) % returns a 0 for finding, 255 for found, and a 128 for index invalid
        SEEK_INDEX (25) % Find worm index, azm only
        SET_USER_LIMIT_MIN (26) % followed by 16 bit number in counts (represents bytes 2 and 3 of 32 bit position)
        SET_USER_LIMIT_MAX (27) % should return 16 bit number (received from
                                % MTR_SET_SLEW_LIMIT), and COUNTS_IN_90_DEGREES (??)
        GET_USER_LIMIT_MIN (28)
        GET_USER_LIMIT_MAX (29)
        IS_USER_LIMIT_ENABLED (30)
        SET_USER_LIMIT_ENABLED (31) % followed by true(1)/false(0)
        SET_CUSTOM_RATE9 (32) % followed by new user defined Rate9 as 16 bit [milli-degree/s]
        GET_CUSTOM_RATE9 (33) % followed by TRUE(1)/FALSE(0)
        SET_CUSTOM_RATE9_ENA (34)
        GET_CUSTOM_RATE9_ENA (35)
        MOVE_POS   (36)         % send move rate 0-9
        MOVE_NEG   (37)
        AUX_GUIDE    (38)  % inferred from INDI/celestrondriver.cpp
        IS_AUX_GUIDE_ACTIVE  (39)  % inferred from INDI/celestrondriver.cpp
        HS_CALIBRATION_ENABLE (42)  % send 0 to start or 1 to stop
        IS_HS_CALIBRATED (43) % returns 2 bytes [0] done, [1] state 0-12
        GET_HS_POSITIONS (44) % returns 2 uint32_t for the low side and high side limits. (typically < 65535)
        EEPROM_READ (48)
        EEPROM_WRITE (49)
        PROGRAM_READ (50)
        ENABLE_CORDWRAP  (56)
        DISABLE_CORDWRAP (57)
        SET_CORDWRAP_POS (58) %followed by 16/24 bit BAM that is the position not to pass through
        POLL_CORDWRAP    (59)
        GET_CORDWRAP_POS (60)
        SET_SHUTTER (61) % command shutter release (on / off)
        GET_POS_BACKLASH (64)
        GET_NEG_BACKLASH (65)
        SET_AUTOGUIDE_RATE (70) % 8 byte autoguide rate in 1/256th's of sidereal rate
        GET_AUTOGUIDE_RATE (71)
        SET_SWITCH_CALIBRATION (72) % 24 bit bam to the switch calibration
        GET_SWITCH_CALIBRATION (73) % AZbd and ALbd reply with no data,
                                    % ALTI and AZIM don't
        SET_PRN_VALUE (74) % 4 byte number
        GET_PRN_VALUE (75)
        SEND_WARNING (80) % 1 byte of data, warning number
                          %   0 battery low, 1 slew limit reached, 2 switched
                          %   reached, 3 switched unknown
        SEND_ERROR (81)
        SET_PID_KP (91) % 16 bit integer
        SET_PID_KI (92) % 16 bit integer
        SET_PID_KD (93) % 16 bit integer
        ENABLE_PID_ANALYSIS (95)
        PROGRAM_ENTER  (129) % not in motor_commands.h
        PROGRAM_INIT   (130) % not in motor_commands.h
        PROGRAM_DATA   (131) % not in motor_commands.h
        PROGRAM_END    (132) % not in motor_commands.h
        PROGRAMMER_ENABLE (138) % goto bootloader
        PROGRAMMER_SOP (139) % prepare to receive data
        PROGRAMMER_DATA (140) % programming data
        PROGRAMMER_DISABLE (141) % clean up and return to normal operation
        DEBUG1 (224)
        DEBUG2 (225)
        DEBUG3 (226)
        GET_HARDSWITCH_ENABLE (238) %  if hardware switch is on 0 if it is off
        SET_HARDSWITCH_ENABLE (239)
        UNRECOGNIZED_COMMAND (240)
        DEBUG_SENDINT (241) % Sends a single integer, MSB first
        GET_CHIPVERSION (250)
        GET_BOOTVERSION (251)
        GET_APPROACH (252) % 1 if direction of final approach is to be negative, 0 if positive
        SET_APPROACH (253)
        GET_VER         (254)  % return 2 or 4 bytes major.minor.build       
    end
end

