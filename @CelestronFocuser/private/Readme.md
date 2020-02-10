Matlab allows only one `private` subfolder in a class folder, so we have to
dump all the ancillaries here, even it would be more ordered to group them
differently.

As a rule, files starting with capitals denote classes.

the AUXmsg class (and its ancillary enumerators, and the basic communication methods) would deserve being part of an independent package, if it is to be shared with a general class for the NexStar mount.