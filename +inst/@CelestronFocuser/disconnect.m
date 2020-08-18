function disconnect(F)
% close the serial stream, but don't delete it from workspace
   if(strcmp(F.lastError, 'could not get status, communication problem?'))
       fprintf('Cannot disconnect. communication problem?\n')
   else
      fclose(F.serial_resource);
   end
end
