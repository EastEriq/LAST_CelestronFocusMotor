function disconnect(F)
% close the serial stream, but don't delete it from workspace
   if(strcmp(F.Status,'unknown'))
       F.reportError('Cannot disconnect. communication problem?')
   else
      fclose(F.SerialResource);
   end
end
