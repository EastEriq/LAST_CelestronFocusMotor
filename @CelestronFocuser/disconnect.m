function disconnect(F)
% close the serial stream, but don't delete it from workspace
   fclose(F.serial_resource);
end
