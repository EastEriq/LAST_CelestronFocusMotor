## Celestron Focus Motor driver for LAST

See the project where all this started from: [NexStarMatlab](https://github.com/EastEriq/NexStarMatlab).

This is a trimdown of the former, controlling only the Focus Motor and not the whole NexStar mount assembly. Keep in mind that if all such a mount is to be controlled via a single serial port, this class needs to be augmented with all the functionality of the former project. Augmenting, rather than duplicating, is IMHO the way to go, as all the communication infrastructure (e.g. the infamous AUX protocol) is common.

The AUXmsg class (and its ancillary enumerators, and the basic communication methods) would deserve being part of an independent package, if it is to be shared with a general class for the NexStar mount.
Here, as a rule, files starting with capitals denote classes.


It is left to the responsibility of the LAST integrator to copy or link the files of this project into an `+obs\+instr` tree. I couln't think of any viable directory structure satisfying both `git` project naming constraints (even considering `subtree`s and `submodule`s) and Matlab/MAAT/LAST organization requirements.

<u>Note on connection:</u> On the focuser motor I tried, connecting the computer on to the USB
port of the focuser looked problematic. In many cases we have to use long, amplified cables and
USB hubs (e.g. the hub embedded on the telescope mount for convenient routing), which are a recipe
for failure. On most of the patched connections which I tried, the USB/serial chip disconnected itself within just a few seconds of continuous motor operation, which definitely happens when commanding long
focus strides, or in calibration. It may be for a large part
a matter of weak engineering of the communication module and non-immunity to EMI too. Disconnects and OS reconnects are
easily monitored by `dmesg -wH`; they cause the OS assigning a new `/dev/tty` device each time, are problematic for Matlab as they leave stale serial resources, and in general for stable operation. One may be forced to issue again and again `delete(instrfind)` to release ALL open
resources and scan again all existing serial devices to find the one the focuser reattached to.

## other notes on the focuser itself:

- The focuser remembers its last position and its calibration limits at poweroff.
- Calibration is performed by searching for the lower point of high resistance (high
  drain current, probably) first. Then this is set as zero of the index, and the motor searches
  the upper high resistance point. Once these two points are found, the operating range is set as
  some hundred steps narrower than the points found (I have not understood whether by a fixed number or
  by two current thresholds), and the motor is brought somewhere mid range.
- the motor runs at ~400steps/second. 1000 steps are a full turn. Increasing counts mean CCW rotation.
- On the RASA telecope, 1 turn equals 1mm. CCW rotation pushes inside the mirror, i.e toward the corrector
  plate, i.e. it focuses the telecsope farther.
- the focuser is not made for working when stuck. Among the rest the overcurrent probably causes a voltage drop
  also on the communication circuits, which cause USB-serial drops and disconnects.
- forcing the motor to turn when powered, using a wrench, causes permanent damage to the gearbox.
