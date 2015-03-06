## Pre-Installation #
You must have the following present for a successful installation:

* Access to your system as `root`.
* One of three appropriate frameworks must already be installed.  Only daemontools, runit, and s6 are supported at this time.  Support for nosh may come at a later date but there is no official support yet.
* The file system that will hold the definitions **must** be able to support soft symlinks; this is fairly typical of most installs.
* The file system **must** allow for read-write access of the `/etc/sv` directory.  The /etc/sv directory can be a symlink provided that the target supports read-write access.
* Access to a minimal shell.  Debian's use of `/bin/dash` as a `/bin/sh` replacement is typical.  *This may change in the future with the possible use of a non-shell based launcher, such as Skarnet's `execline`.*
* The following commands must be present in your $PATH setting:
    * `awk`
    * `basename`
    * `cd`
    * `chmod`
    * `chown`
    * `echo`
    * `ln`
    * `ls`
    * `mkdir`
    * `rm`
    * `sed`
    * `test`
    * `wc`

Despite the long list, the majority of installations will have these.  The grid below shows which tools are generally available, for each toolset.

| Command  | GNU |[FreeBSD](https://www.freebsd.org/cgi/man.cgi) | [Toybox](http://landley.net/toybox/status.html) | [Busybox](http://www.busybox.net/downloads/BusyBox.html) |
| ---      | :-: | :-: |  :-:   | :-:     |
| awk      | Yes | Yes | *Pend* | Yes     |
| basename | Yes | Yes |  Yes   | Yes     |
| cd       | Shell | Shell | Shell | Shell  |
| chmod    | Yes | Yes |  Yes   | Yes     |
| chown    | Yes | Yes |  Yes   | Yes     |
| echo     | Yes | Yes |  Yes   | Yes     |
| ln       | Yes | Yes |  Yes   | Yes     |
| ls       | Yes | Yes |  Yes   | Yes     |
| mkdir    | Yes | Yes |  Yes   | Yes     |
| rm       | Yes | Yes |  Yes   | Yes     |
| sed      | Yes | Yes | *Pend* | Yes     |
| test     | Yes | Yes | *Pend* | Yes     |
| wc       | Yes | Yes |  Yes   | Yes     |

Compatibility Grid Legend

* Yes: The command is shown in the list of available commands
* **No**: The command was not found and is not considered available until confirmed to exist.
* *Pend*:  The command is scheduled to be added at some point.  For the present, it effectively is the same as **No**.
* Shell: this is typically a built-in of the shell running the script.

Toybox is still undergoing heavy development and many missing or pending commands may become available in the near future.  If you have embedded needs, such as a read-only file system, please contact me.


## Installation #

Currently, the target directory is assumed to be `/etc/sv`.

Use `mkdir -p /etc/sv ; cp -Rav sv/ /etc/sv/ ; cp -Rav sv/.* /etc/sv/` to copy all of the required definitions and tools.

There are currently five hidden directories inside of `sv` that contain all of the templates and support scripts needed.  They are `sv/.run`, `sv/.log`, `sv/.bin`, `sv/.env`, and `sv/.finish`.  These five directories *must* be copied to your installation as `/etc/sv/.run`, `/etc/sv/.log`, `/etc/sv/.bin`, `/etc/sv/.env`, and `/etc/sv/.finish`, respectively.  **They are required and cannot be omitted.**

*To be written: a small installer that performs all of the copies and ensures correct permissions.*

## Post-Installation #

Run one of `use-daemontools`, `use-runit`, or `use-s6` to switch support between daemontools, runit, or s6 respectively.  The scripts are located in `/etc/sv/.bin` and must be run as `root` from within that directory.  The scripts are very simple and can be easily audited if you are concerned about running setup as `root`.

You can check your new settings after you run your `use-whatever` script by running `check-settings` in the same directory.

Because logging is framework and system dependent, it is disabled by default, with the default logging script pointing to `/bin/true`.  You will need to go into the `/etc/sv/.log` directory and remove the symlink named `run`, and then redefine it to point to one of the logging scripts in that directory.  *This will become the default logging service system-wide, and requires that you have the appropriate logging service already installed.* 

That's it!  The definitions are ready to use.
