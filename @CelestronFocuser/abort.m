        function abort(F)
            try
                F.Send(CelDev.FOCU,AUXcmd.MOVE_POS,0)
            catch
            end
        end
