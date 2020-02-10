        function abort(F)
            try
                F.send(CelDev.FOCU,AUXcmd.MOVE_POS,0)
            catch
            end
        end
