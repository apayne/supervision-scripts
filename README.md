## NOTICE #

There are known design issues that, while not fatal, prevent me from
achieving some of my goals for the project. The project is still viable
if you need to have pre-made scripts for daemontools, runit, or s6
on a Debian-based system. Beyond that, you will need to make changes
to have the project support your environment fully. Because of these
dependencies, and other issues, supervision-scripts will be entering
"maintenance", during which the documentation will be fully updated.
After the documentation is complete, it will be "retired". I will still
be available to answer any questions or concerns even after the project
is "retired", providing a kind of limited support.

Once supervision-scripts is fully retired, I am planning on starting
a new project that will incorporate some of the concepts in supervision-scripts
while working around the design flaws that caused it to be retired in the
first place. When this occurs, I will update this page with the announcement
along with a link to refer to.

## License #

Currently Licensed under MPL 2.0 minus the exclusion clause. Once the project
is declared "retired", the license will be changed to ISC.


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

