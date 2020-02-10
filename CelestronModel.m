classdef CelestronModel < uint8
    % from https://github.com/indilib/indi/blob/master/drivers/telescope/celestrondriver.cpp
    enumeration
        GPS_Series  (1)
        i_Series    (3)
        i_Series_SE (4)
        CGE         (5)
        Advanced_GT (6)
        SLT         (7)
        CPC         (9)
        GT          (10)
        SE_4_5      (11)
        SE_6_8      (12)
        CGE_Pro     (13)
        CGEM_DX     (14)
        LCM         (15)
        Sky_Prodigy (16)
        CPC_Deluxe  (17)
        GT_16       (18)
        StarSeeker  (19)
        AVX         (20)
        Cosmos      (21)
        Evolution   (22)
        CGX         (23)
        CGXL        (24)
        Astrofi     (25)
        SkyWatcher  (26)
    end
end