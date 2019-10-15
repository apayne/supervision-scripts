# Welcome to supervision-scripts


## License #

As of May 3rd, 2016, project uses the ISC license.  All versions prior to that date use the MPL 2.0 license, minus the Part B clause.

## Introduction #

This project aims to provide supervisor run scripts.  Initial support will be given for runit and s6, but there may be additional support for other supervisors in the future.

Prior to May 2016, the project was aimed at providing run scripts that work within Debian, and hopefully other systems.  That emphasis has changed and the project will now aim at producing supervisor and platform agnostic run scripts.  This means that once the project reaches a 1.0 release, you should be able to switch your process supervision to runit or s6 with only minor effort on your part.

Another side goal is to provide an easy way for existing distribution and package maintainers to create run scripts for daemons that fit their environment.  This means less time working on "glue scripts" to support supervision, and more time spent working on the daemon to be supervised.

If you are new to process supervision, you may wish to read up on this suprisingly simple and easily supported idea.  Additionally, a(n incomplete) comparison of supervision frameworks, and their features, [can be found here](https://github.com/apayne/supervision-scripts/blob/master/Comparison.md).


## Project Goals #

* Provide a nearly-complete set of daemon definitions that are reasonably agnostic to the platform they run on.

* Encourage adoption of process supervision by making it easy to incorporate into distributions and packages.

## Features #

* [The template system was used in prior versions, and works well under Debian.](https://bitbucket.org/avery_payne/supervision-scripts/wiki/Templates)

* Newer releases will be distribution-agnostic, and will *not* use [run templates](https://bitbucket.org/avery_payne/supervision-scripts/wiki/Templates).

* Aims towards being supervision-agnostic.

* Support scripts are neutral to system management and can be easily incorporated.

* Logging is included "out of the box". Each definition, by default, receives its own per-daemon logging directory.  You can easily change or disable this to suit your needs.


## Future Plans #

* Test for and support daemotools, freedt, and daemontools-encore.

## Wish List #

* Look at the possibility of a support tool that would read systemd unit files and write ./run files as a result.
