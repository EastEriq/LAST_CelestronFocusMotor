function success=disconnect(F)
% close the serial stream, but don't delete it from workspace
   if(strcmp(F.Status,'unknown'))
       F.reportError('Cannot disconnect focuser on port %s',F.Port)
       success=false;
   else
      fclose(F.SerialResource);
      delete(F.SerialResource)
      success=true;
   end
end
