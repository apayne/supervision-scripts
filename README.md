## Introduction #

The good thing about supervision is that it is simple to understand and 
maintain.  The bad thing is that you typically have to write your own service 
entries to obtain it, and for a live system, the number of scripts to be 
written is in the dozens.  Writing the entries over and over becomes tedious 
and error-prone.  The supervision-scripts project is an attempt to combine 
all of the needed control scripts to allow a single set of process management 
definitions be used under daemontools, and daemontools-alike programs such as 
runit and s6.

The daemon definition scripts should work with most environments.  If you 
are able to use the scripts in your distribution, please contact me and let 
me know.


## Project Goals #

* Provide a nearly-complete set of daemon definitions.

* Encourage adoption of process supervision by making it easy to incorporate 
into distributions and packages.

* Give the user a voice in deciding policy on thier system when possible


## Features #
* A small number of common scripts reduces complexity, bugs, and the amount 
of time needed to create a new definition.  The scripts live in compact, 
hidden directories that stay out of your way.

* Adapts to your supervision framework.  Choose Gerrit Pape's runit, or 
Laurent Bercot's s6.

* Support scripts are neutral to system management and can be easily 
incorporated.  It means they can be used with ignite, anopa, or s6-rc.

* Logging is included "out of the box".  Each definition receives its own 
logging directory.

* System wide defaults are easily switched to suit your needs.  You can 
change the default logger, the location of the run state directory, etc.

* Simple daemons can be quickly defined by hand and incorporated into your 
arrangement(s).

* No need for PID files.

* Optional integration for user-controlled daemons.  A user can have their own 
supervision instance under the control of their account, but attached to the 
master supervision tree.

* Optional dependency handling (not enabled by default - see the documentation 
for details.)


## Future Plans #
* Experimental support for perp.  This is currently written using a shim, but 
untested at this time.  There may be a possibility of directly supporting 
perp using the run-script abstraction mechanism.

* Tenative plans for testing against daemontools, freedt and 
daemontools-encore, all of which share the same design decisions.

* Tenative partial support for nosh (due to a slightly different file 
layout).  Incorporation of daemon defintions into nosh is possible, but nosh 
has additional structural features, such as service ordering, that are not 
included.

## License #

Currently Licensed under MPL 2.0 minus the exclusion clause.  Once the 
project reaches a 0.2 release, I will move to a BSD/MIT style license.
