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
    * `test`
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

## Installation for Service/State Management

### Installing with OpenRC + s6 #

To be determined.

### Installing with Ignite #

To be determined.

### Installing with Anopa #

WARNING: these are tenative instructions and have not been tested; if it breaks, 
you get to keep both pieces.  Follow each of the four steps in sequence.

To install supervision-scripts in an anopa environment:

* `sudo cp -RAv svcdef/ /etc/anopa/services`
* `sudo cp -Rav svcdef/.* /run/services`
* `echo 0 > /run/services/.env/NEEDS_ENABLED`
* `cd /run/services/.bin && sudo ./use-s6 && sudo show-settings`


And now some notes about what these steps mean:

Because it is anticipated that existing package definitions may exist already at 
`/usr/lib/services`, the administrative override of `/etc/anopa/services` is used 
instead, to prevent a destructive overwrite from ocurring.  This recommendation 
will continue until the supervision-scripts project has approached its goal of 
providing near-universal definition coverage and has been fully tested with anopa, 
at which point I will suggest installing into `/usr/lib/services`.
 
Note that the support directories MUST be present for supervision-scripts to work 
correctly, but anopa will require that they be installed in another location.  
Based on current documentation, it appears that `.bin`, `.run`, `.env`, and `.log` 
must be copied to `/run/services` for anopa to support them; this is due to how 
anopa handles service definitions, which (in the case of my installation 
instructions) are copied in-place at runtime from `/etc/anopa/services` to 
`/run/services`.  All of the supervision-scripts definitions make the assumption 
that the support directories live at the same location as the active definitions 
themselves.  That means (in theory) that anopa will copy the definitions to the 
same location as the support directories, and everything will "just work".

Anopa's instance support is not available with supervision-scripts at this time.  I 
am looking at how anopa uses this feature, and will need to determine later if it 
can be supported correctly.

Based on the published specifications found at http://jjacky.com/anopa/, the 
supervision-scripts implementation of `./needs` appears to be compatible with 
anopa's use of the same, including the same type of "fail-on-child-failure" 
behavior.  As much as I would like to say that this was a good design 
decision on my part, it is admittedly and entirely by fortuitous 
circumstance.  Note that anopa's concept of `./wants`, `./after`, and 
`./before` are not implemented in supervision-scripts, nor is there planned 
support for them through supervision-scripts alone.  Anopa makes use of s6's 
features to ensure that a service is fully available, and not just running; 
this makes support for these other directories feasible.  Due to backwards 
compatibility requirements with daemontools and runit (which have only 
rudimentary support via `./check` scripts), supervision-scripts has no such 
provision.  That being said, you must keep NEEDS_ENABLED turned off at all 
times when using anopa.  In theory, this shouldn't be an issue because using 
NEEDS_ENABLED causes `.run/run` to perform a check of the child service 
before attempting to launch it, and because of how ./needs works in both 
anopa and supervision-scripts, you would always end up with either the child 
launched by anopa ahead of time, or the parent's `run` script not executing 
because the child failed to come up properly.  I cannot guarantee that this 
always the case, so you are safer with the feature disabled while anopa 
handles `./needs`.

If needed, you can point ./run/run to an alternative launcher.  Note that 
this shifts the entire *system* to using that launcher; if you need 
per-service definitions shifted, simply override the setting for the service 
instead.


### Installing with s6-rc #

s6-rc has some specific requirements for supervision-scripts to work correctly.
It places definitions into a "source" directory, and then using the `s6-rc-compile`
tool, creates a set of "compiled" definitions to be used by the live system.  The
installation process will focus on converting supervision-scripts definitions into
the format required by `s6-rc-compile`.

The following requirements are needed for supervision-scripts to interact with s6-rc:

* The `./version/` directory in each definition will need to be renamed to `./data/`, and the `./env` symlink moved to point to the correct subdirectory inside of `./data/`.
* Any definition that contains a `./needs/` directory needs to be translated into a `./dependencies` file.
* The `NEEDS_ENABLED` environment variable must be set to zero (which turns off the feature), as s6-rc provides for this feature.
* Out-of-the-box logging for supervision-scripts is broken, as s6-rc replaces the existing logging mechanism.  This will be accomodated by creating separate logging defintions as needed.
* The `.bin`, `.env`, `.log` and `.run` directories are not supported in the "compiled" directory.  To work around this, each support directory will be kept intact in the source directory, and the symlinks in the definitions adjusted accordingly.

Note that the last step is required for the definitions to work, but it also breaks a design feature; you cannot relocate the source definition directory or you will end up with dangling symlinks in the definitions, and by extension, the definitions will stop working.

### 
