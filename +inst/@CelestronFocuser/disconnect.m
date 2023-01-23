function disconnect(F)
% close the serial stream, but don't delete it from workspace
   if(strcmp(F.Status,'unknown'))
       F.reportError('Cannot disconnect focuser on port %s',F.Port)
   else
      fclose(F.SerialResource);
      F.Connected=false;
   end
end
