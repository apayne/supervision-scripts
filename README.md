## Introduction #

The good thing about DJB-styled supervision is that it is simple to understand and maintain.  The bad thing is that you typically have to write your own service entries to obtain it, and for a live system, the number of scripts to be written is in the dozens.  Writing the entries over and over becomes tedious and error-prone.  **Wouldn't it be great if there was a set of definitions pre-written for you?  Imagine the time you would save by not writing all of them!**

The supervision-scripts project is an attempt to combine all of the needed control scripts to allow a single set of process management definitions be used under daemontools/runit/s6.  Installation is through `cp` and configuration is done by running a single, small script, and setting a single symlink.

Development is done with Debian stable but **the scripts should work with most environments.**

## Features #
* Adapts to your framework.  Choose the original DJB daemontools, Gerrit Pape's runit, or Laurent Bercot's s6.
* Common activities use a template system instead of one-off scripts, reducing development time and potential bugs.
* Simple services can be quickly defined if the daemon has minimal requirements.
* Mix-and-match ttys.  Choose between agetty, mingetty, or fgetty.
* Basic integration for user-controlled services.  A user can have their own supervision instance under the control of their account, but attached to the master supervision tree.
* Support scripts live in compact, hidden directories out of your way.

## Pre-Installation #
You must have the following present for a successful installation:

* Access to your system as `root`.
* One of three appropriate frameworks must already be installed.  Only daemontools, runit, and s6 are supported at this time.  Support for nosh may come at a later date but there is no official support yet.
* The file system that will hold the definitions **must** be able to support soft symlinks; this is fairly typical of most installs.
* The file system **must** allow for read-write access of the `/etc/sv` directory.  The /etc/sv directory can be a symlink provided that the target supports read-write access.
* Access to a minimal shell.  Debian's use of `/bin/dash` as a `/bin/sh` replacement is typical.  *This may change in the future with the possible use of a non-shell based launcher, such as Skarnet's `execline`.*
* `awk` accessible from your regular `$PATH`
* `sed` accessible from your regular `$PATH`
* `rm` accessible from your regular `$PATH`
* `ln` accessible from your regular `$PATH`
* `basename' accessible from your regular `$PATH`

Despite the long list, the majority of installations will have this available.  If you have embedded needs, such as a read-only file system, please contact me.

## Installation

Currently, the target directory is assumed to be `/etc/sv`.

Use `mkdir -p /etc/sv ; cp -Rav sv/ /etc/sv/` to copy all of the required definitions and tools.

There are currently four hidden directories inside of `sv` that contain all of the templates and support scripts needed.  They are `sv/.run`, `sv/.log`, `sv/.bin`, and `sv/.finish`.  These four directories must be copied to your installation as `/etc/sv/.run`, `/etc/sv/.log`, `/etc/sv/.bin`, and `/etc/sv/.finish`, respectively.  They are required and cannot be omitted.

*To be written: a small installer that performs all of the copies and ensures correct permissions.*

## Configuration

Run one of `use-daemontools`, `use-runit`, or `use-s6` to switch support between daemontools, runit, or s6 respectively.  The scripts are located in `/etc/sv/.bin` and must be run as `root` from within that directory.  The scripts are very simple and can be easily audited if you are concerned about running setup as `root`.

Because logging is framework and system dependent, it is disabled by default, with the default logging script pointing to `/bin/true`.  You will need to go into the `/etc/sv/.log` directory and remove the symlink named `run`, and then redefine it to point to one of the logging scripts in that directory.  *This will become the default logging service system-wide, and requires that you have the appropriate logging service already installed.* 

That's it!  The definitions are ready to use.