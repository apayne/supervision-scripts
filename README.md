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
* Optional dependency handling (not enabled by default - see below for details)

## Pre-Installation #
You must have the following present for a successful installation:

* Access to your system as `root`.
* One of three appropriate frameworks must already be installed.  Only daemontools, runit, and s6 are supported at this time.  Support for nosh may come at a later date but there is no official support yet.
* The file system that will hold the definitions **must** be able to support soft symlinks; this is fairly typical of most installs.
* The file system **must** allow for read-write access of the `/etc/sv` directory.  The /etc/sv directory can be a symlink provided that the target supports read-write access.
* Access to a minimal shell.  Debian's use of `/bin/dash` as a `/bin/sh` replacement is typical.  *This may change in the future with the possible use of a non-shell based launcher, such as Skarnet's `execline`.*
* `awk` accessible from your regular `$PATH`
* `basename` accessible from your regular `$PATH`
* `cd` accessible from your regular `$PATH`, or as a built-in
* `echo` accessible from your regular `$PATH`, or as a built-in
* `ln` accessible from your regular `$PATH`
* `ls` accessible from your regular `$PATH`, or as a built-in
* `rm` accessible from your regular `$PATH`, or as a built-in
* `sed` accessible from your regular `$PATH`
* `test` accessible from your regular `$PATH`, or as a built-in
* `wc` accessible from your regular `$PATH`, or as a built-in

Despite the long list, the majority of installations will have this available.  If you have embedded needs, such as a read-only file system, please contact me.

*TODO: look at various user-lands and determine if the tools are present; perhaps draw up a small compatibility grid*

## Installation

Currently, the target directory is assumed to be `/etc/sv`.

Use `mkdir -p /etc/sv ; cp -Rav sv/ /etc/sv/ ; cp -Rav sv/.* /etc/sv/` to copy all of the required definitions and tools.

There are currently five hidden directories inside of `sv` that contain all of the templates and support scripts needed.  They are `sv/.run`, `sv/.log`, `sv/.bin`, `sv/.env`, and `sv/.finish`.  These five directories *must* be copied to your installation as `/etc/sv/.run`, `/etc/sv/.log`, `/etc/sv/.bin`, `/etc/sv/.env`, and `/etc/sv/.finish`, respectively.  **They are required and cannot be omitted.**

*To be written: a small installer that performs all of the copies and ensures correct permissions.*

## Configuration

Run one of `use-daemontools`, `use-runit`, or `use-s6` to switch support between daemontools, runit, or s6 respectively.  The scripts are located in `/etc/sv/.bin` and must be run as `root` from within that directory.  The scripts are very simple and can be easily audited if you are concerned about running setup as `root`.

You can check your new settings after you run your `use-whatever` script by running `check-settings` in the same directory.

Because logging is framework and system dependent, it is disabled by default, with the default logging script pointing to `/bin/true`.  You will need to go into the `/etc/sv/.log` directory and remove the symlink named `run`, and then redefine it to point to one of the logging scripts in that directory.  *This will become the default logging service system-wide, and requires that you have the appropriate logging service already installed.* 

That's it!  The definitions are ready to use.

## Additional Features and Options

### User-Defined Services
This feature is meant for a system where a dedicated program, such as `usersv`, isn't available that allows users to join the supervision process tree and manage their own services.  It is done with a definition based on a specially-named template, which in turn will launch a sub-tree that can be controlled by that user.  Because the feature is script-based, it will lack certain feature, such as dynamic addition of users, but for most it will suffice.

To add a user, the administrator simply creates a new service definition with a special name, and then adds that definition to the system's `/service` directory.

The steps are:

1. `mkdir /etc/sv/(framework)-(user)`
2. `ln -s /etc/sv/.run/run-user-service /etc/sv/(framework)-(user)/run`
3. `ln -s /etc/sv/(framework)-(user) /service/`

Where:

* (framework) is one of `svscan` (daemontools), `runsvdir` (runit), or `s6-svscan` (s6).
* (user) is the user's name as it appears in `/home`.

Let's say I have a user `avery` that wants to have their own services, for whatever reason.  In my example, I'm running `s6` as my framework, so I do:

    mkdir /etc/sv/s6-svscan-avery
    ln -s /etc/sv/.run/run-user-service /etc/sv/s6-svscan-avery/run
    ln -s /etc/sv/s6-svscan-avery /service/

This will start `s6-svscan` on /home/avery/service and any service definitions in that directory will be brought up as well.  If I was running `runit` instead, the name would be `runsvdir-avery`, and for `daemontools` it would be `svscan-avery`.

### Dependency Resolution
This feature is meant as an option of last resort.  Enabling it should be considered carefully and with grave diligence.  Because of several requirements, the feature is not enabled by default.

Here is what you gain:
* Everything is already defined.  You don't lift a finger.
* Service A needs service B, service B will start before service A
* Service chain sequencing, where A needs B, and B needs C; C will start before B, and B before A
* Chains can be trees; it doesn't matter that A and B have chains that ultimately lead to C, because if C is running everything's ok.
* Clear logging of failure modes due to issues with dependencies.  If A can't start because B won't, then A will complain about B's problems inside of A's log.

Here is what you lose:
* Enabling this feature on a system that has true dependency resolution will most assuredly break something.  You get to keep both pieces.
* It will only apply to services that start after it has been enabled.  It is not retroactive.
* You can no longer rename a service definition without renaming all of the links to `./needs` directories elsewhere.  Doing so will break dependency definitions.  I do not recommend this at all, and cannot support any issues surrounding this action.
* Dependency checks are done within the confines of `./check` definitions or the limits of the framework's `check` command; it is still possible for a service to respond with "up" but not be done initializing, so it really isn't "up" yet.  Therefore, the guarantee that B is really up before A is much, much weaker.  
* While highly not likely, it is possible to develop a race condition where services oscillate between up and down due to timing issues.  This should be very very rare, but I will warn you in advance.

So, in exchange for this convenience feature, you will have a policy decision set for you, you loose some choices, and some supervision guarantees may be much weaker.  It should only be used on systems that (a) do **not** already have dependency management and (b) in your use case, the desire to use the feature outweighs any costs.
That being all said, you turn it on by doing this as `root` in a shell:

    echo 1 > /etc/sv/.env/NEEDS_ENABLED

Now you start your service.  That's it.  Scary, isn't it?
