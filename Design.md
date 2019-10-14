# Introduction
This short document is meant to lay out a basic problem, noting various issues, providing possible solutions, making design choices to match those solutions, and discussing the rationale behind each design.

At this time I do not claim to be an expert in process management. I am approaching this from a pragmatic standpoint of trying to provide a missing but necessary piece of software and data to process supervision. As I work through this project I will develop further expertise and eventually will have a firm understanding of all nuances; just not right now.

# What are we really trying to solve?
There are people that would like to use supervisor frameworks on their systems but can't, typically because:

* There is no support from the distribution or vendor
* Even if there is minimal support, you have to write all of the run scripts needed to make things work
* Any run scripts written are specific to the system and supervisor they are written for

# A short and limited background on process supervision concepts
To my limited knowledge, the original supervision concept can be traced back to Daniel J. Bernstein. The following influences are noted in the design:

* a small group of programs that follow "do one thing, do it well",
* each program should be as simple as possible, so it can be understood,
* smaller and simpler programs usually (but not always) translated into more portable programs,
* smaller and simpler programs usually (but not always) translated into more secure programs
* reduce the amount of parsing needed, to reduce possible unintended behaviors at runtime

To facilitate large numbers of daemons, a directory scanning program would look for entries in the filesystem and launch a supervisor associated with each entry. This allowed you to start several daemons and control them from a single point. The supervisor is a program that would launch another program, typically a daemon, and monitor it. In the event the child program would terminate unexpectedly, the supervisor would launch it again. Each supervisor would load a program called "run" and execute it. The supervisor didn't care what the "run" program was, it simply started it and observed its new child process.

The supervisor also had a secondary task. It could capture the output of the child program and forward it to another process. With some clever work, this was turned into a logging service that directly logged to disk. By doing so, it eliminates the need for a central logger, or the complexity that comes with it.

In addition to this, the concept of chain-loading was introduced. A program would run, perform one or two functions, and then run a program named on its command line. This could be extended to more than one program, so that a "chain" of programs "load" each other in succession. Because the program would perform one function and then proceed to load the next program, it reduced the chances of unintended interactions in the run script itself.

There were a lot of problems solved by using this combined approach by using the scan process, the supervisor, and chain-loading:

* PID files are not necessary because the supervisor tracks the child directly.
* No PID files meant no stale PIDs to confuse things or cause problems with other programs that were assigned the stale PID.
* The supervisor would handle the child/daemon's output, eliminating the need to "daemonize" into a background process.
* ...by extension, ANY program could be made into a daemon without the need to support "daemonizing" into a background process.
* ensuring that a syslog process is available is no longer necessary, as the supervisor will also track the logging program used for the output of the daemon.
* the run program typically was a very small shell script.
* chainloading can reduce the number of interactions possible from environment variables by carefully controlling the sequence of execution, but it is not required
* there are many other reasons as well.

This approach was much admired, but daemontools had some minor encumberances placed upon it when it was released. It has since entered the public domain and is no longer actively maintained. There are a few arrangements that were inspired by this approach:

* daemontools-encore
* freedt
* runit
* s6

There were also some daemontools-alike environments that did not follow the scanner-superivisor-runscript approach directly but were influenced in spirit:

* perp
* nosh

# Remaining problems facing supervision
Despite the advances gained from supervision, there are still some issues remaining to be tackled.

* the flexibility of a run program being written in shell script came with the trade-off that more complicated scripts may have portability issues, as there isn't a real "shell script" standard; all shells have their own dialects that may or may not be compatible between each other
* shell scripts tend to have "statically mapped" information embedded in them, which ties the context of their execution to the specific machine they were written for
* every shell script typically contains supervisor commands that are specific to that installation, i.e. the tools used by runit and s6 perform very similar functions but are called by different names.
* static mappings also mean user and group names used for "underprivileged" daemons are not reusable between installations
* this is very limited adoption in live deployments and distributions, this creates a chicken-and-egg problem where inclusion won't happen until there are scripts, but scripts won't happen until inclusion is needed
* daemon settings can change between even minor releases, which means upgrading a minor revision of a software package in-place could lead to the daemon in the package not launching after the upgrade was completed.
* some supervisors work within a larger framework that manages the system state entirely, and not just the services provided.

All of these issues can be addressed.

# Proposals to address issues
## Regarding adoption and uptake
We can kick-start the process of adoption by providing many, many definitions that are "ready out of the box". This removes the need for a distribution package maintainer to initially develop their own scripts, allowing them to direct their attention elsewhere instead of worrying about supporting this-or-that supervisor. It also makes it possible for distribution maintainers to easily adopt supervision by simply including the scripts as part of the installation.

## Regarding run script portability by system
By carefully minimizing the use of specific shell features, we can increase the number of shells that will work with run scripts, and by extension, the number of systems. There is enough of a common grammar that a simple script might be written to work in several different shells. At a later point, all of the parsing can be completely removed by "compiling" the shell scripts with the specific commands needed, removing any differences of interpretation.

## Regarding static path and device information embedded in run scripts
The most obvious solution would be to make run scripts parametric via the use of environment variables that can be defined in bulk, and when needed, the root account can easily override their meaning by hand. This works neatly with the use of settings stored in an envdir directory.

## Regarding the need for specific, unique commands for each supervisor
Many of the supervisor commands have a high degree of interchangeability. This can be used to make the supervisor commands parametric, substituting the correct chainload command from the supervisor suite for the desired behavior. Fortunately, most of the commands for supervisors can be interchanged with a little work.

## Regarding static mapping of user and group names
We can further extend the parametric method above to include these as variables that are preset during installation. This implies that a small database of settings be kept as part of the solution. All a SysAdmin or distribution maintainer would need to do is run a single program to generate the correct user and group name settings for a given system.

## Regarding daemon settings tied directly to a specific release
As we are discussing a database of user and group settings, we could also consider a database containing a set of proper daemon options based on the version number being employed. This further removes the need to worry about breakage between releases, and even allows for "rollbacks" to prior versions when the SysAdmin requires it.

## Regarding incorporation into systems with state management
The majority of observed state managers derive their definitions from a set location and copy active daemon settings to a working directory. This allows definitions to be maintained or updated without interfering with the system. As such, definitions will not be targeted to a live environment, but to a repository of definitions and settings that will be copied or used later.

# Basic design & rationalizations
A single definition directory on the target system to store all definitions. The directory will be named /svcdef and can exist anywhere the systems administrator would like or need it to be. This allows the administrator the ability to pick up and move all of the definitions, while keeping them tidy at a single location.

Inside of /svcdef would be additional directories, one for each daemon that needs to be supervised. The name of a definition directory typically determines how it is controlled from the command line, and how it displays when looking at a list of processes. There are known instances of installations that use different names between the control script for a daemon and the daemon's actual name. Apache is a good example, which may have controls existing as “apache”, “apache2”, or “httpd” depending on which system you are using. Because of the confusion this causes, the name of the directory will match the name of the daemon, unless the daemon happens to have a name which might conflict with another definition. In that case, the common name of the project will be used. In our Apache example, the definition would be /httpd since it is the name of the actual Apache daemon. If it was determined that there is another httpd process by the same name, then the definition would be changed to /apache, and the 2nd httpd would have its name changed to reflect its project name as well. Note: this means under specific circumstances we may have definitions that are determined to be deprecated at an unknown future date due to an ongoing discovery process, although the likelihood of this is low. There is also a risk involved when a project changes its name, as this implies a name change for the service definition as well; using the actual daemon name mitigates that problem.

All daemon launches from run scripts follow a general pattern of behavior:

  1. stdout and stderr are redirected into a single stream to be captured by the supervisor of the daemon. This is done as early as possible to ensure that any errors in the run script are captured to a log.
  2. in rare circumstances, a pre-launch program must be run before the daemon can be run. There are known examples that require this, such as dbus needing a GUID assigned, or squid needing a one-time run with the -Z option to create the cache directory structure. A basic "call hook" should be present to detect if this is needed and call a separate program prior to completing the daemon's launch.
  3. if needed, a run state directory is created on the system, and file permissions assigned to it.
  4. if needed, a fifo is created, and file permissions assigned to it.
  5. environmental settings are loaded
  6. additional launch requirements are enforced via chain-load, such as setting or changing UID or GID.
  7. the daemon is launched with the required arguments
  8. The run script in the daemon directory will be specifically tailored for the environment it is launching in by being “compiled” prior to use. By using a pre-process phase, we can allow the introduction of variables to the script that in turn will “compile” into the correct commands through substitution. The compile process can be extended to mapping system-specific settings, user and group IDs, and even to the programs used with a given supervisor. This eliminates several portability issues related to name mapping, pathing, etc. as mentioned above.

There will be in all cases a /log subdirectory in the daemon directory. While there is no mandate to enforce logging for all daemons, it makes sense to provide for it by default and let the administrator decide if they want it enabled or not. Should a given supervisor not have a fall-back logging mechanism, this ensures that logging will take place regardless of that.

In the /log directory will be the appropriate run script needed to launch any affiliated supervisor logging. The run script will be “compiled” just like the daemon's run script.

Updated 2016-07-03
