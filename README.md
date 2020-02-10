##Celestron Focus Motor driver for LAST

See the project where all this started from: [NexStarMatlab](https://github.com/EastEriq/NexStarMatlab).

This is a trimdown of the former, controlling only the Focus Motor and not the whole NexStar mount assembly. Keep in mind that if all such a mount is to be controlled via a single serial port, this class needs to be augmented with all the functionality of the former project. Augmenting, rather than duplicating, is IMHO the way to go, as all the communication infrastructure (e.g. the infamous AUX protocol) is common.

It is left to the responsibility of the LAST integrator to copy or link the files of this project into an `+obs\+instr` tree. I couln't think of any viable directory structure satisfying both `git` project naming constraints (even considering `subtree`s and `submodule`s) and Matlab/MAAT/LAST organization requirements.