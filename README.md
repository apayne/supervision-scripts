## Introduction #

The good thing about DJB-styled supervision is that it is simple to understand 
and maintain.  The bad thing is that you typically have to write your own 
service entries to obtain it, and for a live system, the number of scripts to 
be written is in the dozens.  Writing the entries over and over becomes tedious 
and error-prone.  The supervision-scripts project is an attempt to combine 
all of the needed control scripts to allow a single set of process management 
definitions be used under daemontools/runit/s6.

Development is done with Debian 7 but **the scripts should work with most 
environments.**  If you are able to use the scripts in your distribution,
please contact me and let me know.

## Project Goals #

* Encourage adoption of process supervision by increasing use

* Provide a complete set of service definitions to encourage distributions to use
process supervision by reducing the maintainer's load

* Give the user a choice whenever possible

* Be as friendly as possible to the widest range of inits, kernels, etc. so the user has choices

* Be as agnostic as possible with regard to the supervisor used, so the user has choices

* Be as agnostic as possible with regard to logging used, so the user has choices

* Provide enhancements that don't conflict with the above goals, so the user has choices


## Features #
* Adapts to your framework.  Choose the original DJB daemontools, Gerrit Pape's 
runit, or Laurent Bercot's s6.

* Experimental support for perp (untested).

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