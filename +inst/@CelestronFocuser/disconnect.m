function disconnect(F)
% close the serial stream, but don't delete it from workspace
   if(strcmp(F.LastError, 'could not get status, communication problem?'))
       fprintf('Cannot disconnect. communication problem?\n')
   else
      fclose(F.SerialResource);
   end
end
