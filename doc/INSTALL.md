## Pre-Installation #
You must have the following present for a successful installation:

* Access to your system as `root`.
* One of three appropriate frameworks must already be installed.  Only daemontools, runit, and s6 are supported at this time.  Support for nosh may come at a later date but there is no official support yet.
* The file system that will hold the definitions **must** be able to support soft symlinks; this is fairly typical of most installs.
* The file system **must** allow for read-write access of the `/etc/svcdef` directory.  The /etc/svcdef directory can be a symlink provided that the target supports read-write access.
* Access to a minimal shell.  Debian's use of `/bin/dash` as a `/bin/sh` replacement is typical.  *This may change in the future with the possible use of a non-shell based launcher, such as Skarnet's `execline`.*
* The following commands must be present in your $PATH setting:
    * `awk`
    * `basename`
    * `chmod`
    * `chown`
    * `echo`
    * `ln`
    * `ls`
    * `mkdir`
    * `rm`
    * `sed`
    * `wc`

Despite the long list, the majority of installations will have these.  The grid below shows which tools are generally available, for each toolset.

| Command  | GNU |[FreeBSD](https://www.freebsd.org/cgi/man.cgi) | [Toybox](http://landley.net/toybox/status.html) | [Busybox](http://www.busybox.net/downloads/BusyBox.html) |
| ---      | :-: | :-: |  :-:   | :-:     |
| awk      | Yes | Yes | *Pend* | Yes     |
| basename | Yes | Yes |  Yes   | Yes     |
| chmod    | Yes | Yes |  Yes   | Yes     |
| chown    | Yes | Yes |  Yes   | Yes     |
| echo     | Yes | Yes |  Yes   | Yes     |
| ln       | Yes | Yes |  Yes   | Yes     |
| ls       | Yes | Yes |  Yes   | Yes     |
| mkdir    | Yes | Yes |  Yes   | Yes     |
| rm       | Yes | Yes |  Yes   | Yes     |
| sed      | Yes | Yes | *Pend* | Yes     |
| wc       | Yes | Yes |  Yes   | Yes     |

Compatibility Grid Legend

* Yes: The command is shown in the list of available commands
* **No**: The command was not found and is not considered available until confirmed to exist.
* *Pend*:  The command is scheduled to be added at some point.  For the present, it effectively is the same as **No**.
* Shell: this is typically a built-in of the shell running the script.

Toybox is still undergoing heavy development and many missing or pending commands may become available in the near future.  If you have embedded needs, such as a read-only file system, please contact me.


## Installation #

Currently, the target directory is assumed to be `/etc/svcdef`, although this is not a hard requirement.  The scripts are relocatable to any directory and use relative pathing when accessing various common scripts and settings.  Other viable locations are /etc/service, /var/svcdef, /var/service, or any other writable directory.  Note that you will need to ensure that your supervision tree is looking at the installation directory; beyond that, the scripts will take care of the rest once they are set up.  For the sake of discussion and the remainder of this document, we will assume that we are installing to /etc/svcdef as a location.

Use `mkdir -p /etc/svcdef ; cp -Rav svcdef/ /etc/svcdef/ ; cp -Rav svcdef/.* /etc/svcdef/` to copy all of the required definitions and tools.

There are currently five hidden directories inside of `sv` that contain all of the templates and support scripts needed.  They are `sv/.run`, `sv/.log`, `sv/.bin`, `sv/.env`, and `sv/.finish`.  These five directories *must* be copied to your installation as `/etc/svcdef/.run`, `/etc/svcdef/.log`, `/etc/svcdef/.bin`, `/etc/svcdef/.env`, and `/etc/svcdef/.finish`, respectively.  **They are required and cannot be omitted.**

*To be written: a small installer that performs all of the copies and ensures correct permissions.*

## Post-Installation #

Run one of `use-daemontools`, `use-runit`, or `use-s6` to switch support between daemontools, runit, or s6 respectively.  The scripts are located in `/etc/svcdef/.bin` and must be run as `root` from within that directory.  The scripts are very simple and can be easily audited if you are concerned about running setup as `root`.

You can check your new settings after you run your `use-whatever` script by running `check-settings` in the same directory.

Because logging is framework and system dependent, it is disabled by default, with the default logging script pointing to `/bin/true`.  You will need to go into the `/etc/svcdef/.log` directory and remove the symlink named `run`, and then redefine it to point to one of the logging scripts in that directory.  *This will become the default logging service system-wide, and requires that you have the appropriate logging service already installed.*  Alternatively, you can choose to use the autolog function, although this feature is experimental.

That's it!  The definitions are ready to use.

