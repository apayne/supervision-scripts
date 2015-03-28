## Introduction #

The good thing about DJB-styled supervision is that it is simple to understand 
and maintain.  The bad thing is that you typically have to write your own 
service entries to obtain it, and for a live system, the number of scripts to 
be written is in the dozens.  Writing the entries over and over becomes tedious 
and error-prone.  **Wouldn't it be great if there was a set of definitions 
pre-written for you?** The supervision-scripts project is an attempt to combine 
all of the needed control scripts to allow a single set of process management 
definitions be used under daemontools/runit/s6.

Development is done with Debian 7 but **the scripts should work with most 
environments.**

## Features #
* Adapts to your framework.  Choose the original DJB daemontools, Gerrit Pape's 
runit, or Laurent Bercot's s6.

* No need for PID files.  PID file support will be completely removed in the 0.1 release. 

* System wide defaults mean you can easily switch run directories, etc. with just a few settings. 

* Mix logging services from different frameworks

* Per-definition logging overrides are easily done with a single symlink.

* A common set of scripts reduces complexity, bugs, and the amount of time needed to create a new definition. 

* Simple services can be quickly defined.

* Mix-and-match ttys.  Choose between agetty, mingetty, or fgetty.

* Support scripts live in compact, hidden directories out of your way.

* Optional integration for user-controlled services.  A user can have their own 
supervision instance under the control of their account, but attached to the 
master supervision tree.

* Optional dependency handling (not enabled by default - see the documentation 
for details.)

* Optional "auto log" feature detects appropriate logging service to use based on the framework you have designated. 

## Future Plans #
* Tenative plans for supporting freedt, daemontools-encore, nosh, and perp.
* Tenative plans for supporting a choice between execline and /bin/sh.

## License #
Currently Licensed under MPL 2.0 minus the exclusion clause.  Once the project reaches a 0.2 release, I will move to a BSD/MIT style license.