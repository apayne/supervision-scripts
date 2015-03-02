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

* Common activities use a template system instead of one-off scripts, reducing 
development time and potential bugs.

* Simple services can be quickly defined if the daemon has minimal 
requirements.

* Mix-and-match ttys.  Choose between agetty, mingetty, or fgetty.

* Support scripts live in compact, hidden directories out of your way.

* Optional integration for user-controlled services.  A user can have their own 
supervision instance under the control of their account, but attached to the 
master supervision tree.

* Optional dependency handling (not enabled by default - see the documentation 
for details.)

## Future Plans #
* Tenative plans for supporting freedt, daemontools-encore, nosh, and perp.
* Tenative plans for supporting a choice between execline and /bin/sh.

