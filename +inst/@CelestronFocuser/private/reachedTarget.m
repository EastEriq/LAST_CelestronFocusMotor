function reached=reachedTarget(F)
    resp=F.query(inst.CelDev.FOCU, inst.AUXcmd.IS_GOTO_OVER);
    reached=(resp.bindata==255);
