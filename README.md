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

A windows GUI from Celestron exists, and it has controls for three velocity settings, and a backlash value of 0...99.
There are AUXmsg modes for GOTO_SLOW and GOTO_FAST, and I have seen them working, but I don't know if there is an
undocumented code for the intermediate velocity.

Also,there are AUXmsg codes for getting and setting positive and negative backlashes, but I'm not sure
of what is their effect. Maybe they don't apply to the focuser, but tho the NexStar mount motors. Experimenting
with them I could not conclude if they add sometimes a small jerk of the motor before or after the move,
or if I was playing with a defective focuser. With the Windows GUI the control seemed to change the acceleration/deceleration rate.

## Notes on the focuser itself:

- The focuser remembers its last position and its calibration limits at poweroff.
- If the focuser receives a new position command while it is moving, it immediately changes
  its target to the new position. If many commands are received, the focuser will go to
  the last of the positions. If a new position is command is received while moving in one
  direction, the focuser will decelerate a bit before moving in the opposite direction,
  if asked to.
- Calibration is performed by searching for the lower point of high resistance (high
  drain current, probably) first. Then this is set as zero of the index, and the motor searches
  the upper high resistance point. Once these two points are found, the operating range is set
  as the value of the upper index. The range limits are then defined, by Celestron choice, to be
  _operating_range_*[1,19]/18. The motor is then moved somewhere mid range.
- the motor runs at 355.6 steps/second (measured with `testing/turningspeed`). Movement follows an S profile,
  with ~1 sec to accelerate to full speed and decelerate to stop.
  1000 steps are a full turn (0r maybe only 960, see below). Increasing counts mean CCW rotation.
- there is also a SlowMotion mode. In it the speed is ~80steps/second.
- The step counter wraps around at 60000 (not 2^16). This is seen when attempting the calibration of a
  focuser mechanically disconnected from the focus screw.
- Internally, the focuser has a small DC motor, likely driven as servo in closed feedback loop. On top
  of the motor, a slit disk with 45 slots is read by a photodiode.
  The axis of the motor does one turn for a commanded movement of 3 ticks. The motor drives a
  gearbox, apparently with a demultiplication ratio of 320. Eight turns of the motor axis
  move the main 40 teeth cog of one tooth.
- On the RASA telecope, 1 turn equals 0.75mm (we measured the thread of the guiding screw). CCW
  rotation pushes inside the mirror, i.e toward the corrector
  plate, i.e. it focuses the telescope farther. This corresponds to increasing tick count.
  The total range is seen to be ~35000 steps, i.e.
  the tick limits may result in ~[1500,36500].
- Thermal expansion of the telescope tube plays in in that when the temperature increases, the
  tube extends, and the mirror has to be pushed in in order to maintain focus, i.e. tick numbers
  have to be increased. We measured a slope of ~19 ticks/°C, though with differences from one telescope
  to the next.
- The focuser is not made for working when stuck. Among the rest the overcurrent probably causes a voltage drop
  also on the communication circuits, which cause USB-serial drops and disconnects.
- Forcing the motor to turn when powered, using a wrench, causes permanent damage to the gearbox.
