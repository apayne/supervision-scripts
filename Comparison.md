Here are various supervision-inspired or supervision-alike frameworks compared together.  This is not meant to be an exhaustive list, and certainly there are some unrelated concepts mixed into the matrix below.  It does however provide a basic starting point for seeing "the big picture" when it comes to comparing frameworks.  In terms of the supervision-scripts project, I use it to keep track of what tool matches what, what tools are missing, where can I get a quick set of links to see the original documentation, etc.

Revised 2015-07-13: added suggestions from "Guillermo":http://www.mail-archive.com/supervision@list.skarnet.org/msg00832.html and "Laurent Bercot":http://www.mail-archive.com/supervision@list.skarnet.org/msg00833.html. 

| | "daemontools":http://cr.yp.to/daemontools.html | "daemontools-encore":http://untroubled.org/daemontools-encore/ | "freedt":http://offog.org/code/freedt/ | "runit":http://smarden.org/runit | "perp":http://b0llix.net/perp/ | "s6":http://skarnet.org/software/s6 | "nosh":http://homepage.ntlworld.com/jonathan.deboynepollard/Softwares/nosh.html |
| ---   | --- | --- | --- | --- | --- | --- | --- |
| *Summary* |  |  |  |  |  |  |  |
| ---   | --- | --- | --- | --- | --- | --- | --- |
| Author | Daniel J. Bernstein | Bruce Guenter | Adam Sampson | Gerrit Pape | Wayne Marshall | Laurent Bercot | Jonathan de Boyne Pollard |
| License | Public Domain | "ISC-like":https://github.com/bruceg/daemontools-encore/blob/master/LICENSE | described as "OpenBSD or ISC-like" | modified BSD |  "Custom":http://b0llix.net/perp/site.cgi?page=LICENSE | ISC | ISC (with provisions for others) |
| Maintained | No | Yes | Yes | Yes | Yes | Yes | Yes |
| *Compatibility* |  |  |  |  |  |  |  |
| ---   | --- | --- | --- | --- | --- | --- | --- |
| Linux | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| FreeBSD | unknown | unknown | unknown | Yes | unknown | Yes | Yes |
| OpenBSD | unknown | unknown | unknown | unknown | unknown | Yes | unknown |
| NetBSD | unknown | unknown | unknown | unknown | unknown | Yes | unknown |
| Solaris | unknown | unknown | unknown | unknown | unknown | Yes | unknown |
| AIX | unknown | unknown | unknown | unknown | unknown | unknown | unknown |
| Darwin | unknown | unknown | unknown | unknown | unknown | Yes | unknown |
| *Source & Build Options* |   |  |  |  |  |  |  |
| ---   | --- | --- | --- | --- | --- | --- | --- |
| Source | "tarball":http://cr.yp.to/daemontools/install.html | "via Github":https://github.com/bruceg/daemontools-encore or "tarball":http://untroubled.org/daemontools-encore/ | "via Git":http://offog.org/git/freedt.git/ or "tarball":http://offog.org/code/freedt/ | "tarball":http://smarden.org/runit/install.html | "tarball":http://b0llix.net/perp/ | "via Github":https://github.com/skarnet/s6 or "tarball":http://skarnet.org/software/s6/ | "tarball":http://homepage.ntlworld.com/jonathan.deboynepollard/Softwares/nosh/source-package.html |
| supports slashpackage install  | Yes | unknown ^1^ | unknown ^1^ | Yes | unknown ^1^ | Yes | Yes, via source |
| supports musl | unknown ^1^ | unknown ^1^ | unknown ^1^ | "Yes":https://aur.archlinux.org/packages/runit-musl/ | unknown ^1^ | "Yes":https://github.com/skarnet/s6/blob/master/INSTALL | unknown ^1^ |
| supports dietlibc | unknown ^1^ | unknown ^1^ | unknown ^1^ | Yes | unknown ^1^| "Yes":https://github.com/skarnet/s6/blob/master/INSTALL | unknown ^1^ |
| *Runscript & Framework Support* |  |  |  |  |  |  |  |
| ---   | --- | --- | --- | --- | --- | --- | --- |
| comes with ready-made scripts | No | No | No | Examples | No | Examples | Yes |
| "ignite":https://github.com/chneukirchen/ignite | No | No | No | Yes | No | No | No |
| "supervision-scripts":https://bitbucket.org/avery_payne/supervision-scripts/src | Untested | Untested | Untested | Yes | Experimental | Untested | Possibly |
| "supervision":https://github.com/tokiclover/supervision | Possibly | Possibly | Possibly | Yes | No | Possibly | Possibly |
| "anopa":https://github.com/jjk-jacky/anopa | No | No | No | No | No | Yes | No |
| "s6-rc":https://github.com/skarnet/s6-rc | No | No | No | No | No | "Yes":http://skarnet.org/software/s6-rc/ | No |
| *Init Support* |  |  |  |  |  |  |  |
| ---   | --- | --- | --- | --- | --- | --- | --- |
| comes with init | No | No | Unknown | runit-init | Unknown | (separate package) output of s6-linix-init | system-manager |
| supports using a supervisor-as-init | "Kinda":http://code.dogmap.org./svscan-1/ | Unknown | Unknown | N/A | Unknown | "Yes":http://skarnet.org/software/s6/s6-svscan-1.html | N/A |
| *Supervisor Programs* |  |  |  |  |  |  |  |
| ---   | --- | --- | --- | --- | --- | --- | --- |
| | svscanboot | svscanboot | N/A | "Stage 2 Script" | N/A | Provided as example | N/A | 
| | svscan | svscan | unknown | runsvdir | via perpd| s6-svscan | unknown |
| | supervise | supervise | unknown | runsv | via perpd | s6-supervise | service-manager |
| *Service Control  & Communication* |  |  |  |  |  |  |  |
| ---   | --- | --- | --- | --- | --- | --- | --- |
| | svc | svc | unknown | sv | unknown | s6-svc | service-control |
| | svok | svok | unknown | sv status $dir > /dev/null | unknown | s6-svok | service-is-ok? | 
| | svstat | svstat | unknown | "sv status" | unknown | s6-svstat | service-status? |
| *Launcher / Chainloader* |  |  |  |  |  |  |  |
| ---   | --- | --- | --- | --- | --- | --- | --- |
| | typically /bin/sh | typically /bin/sh | typically /bin/sh | typically /bin/sh | typically /bin/sh | /bin/sh or execline | nosh | 
| *Chainloading Tools* |  |  |  |  |  |  |  |
| ---   | --- | --- | --- | --- | --- | --- | --- |
| force a service to stay in the foreground | fghack | fghack | N/A | N/A | N/A | s6-fghack | N/A | 
| create a new session and make the service the session leader | pgrphack | pgrphack | N/A | chpst ^2^ | N/A |  s6-setsid |  setsid | 
| set the runtime UID and GID of a command | setuidgid | setuidgid | N/A | chpst ^2^ | N/A | s6-setuidgid | setuidgid? | 
| set the UID and GID environment variables | envuidgid | envuidgid | N/A | chpst ^2^ | N/A | s6-envuidgid | envuidgid? | 
| load environment variables from a directory | envdir | envdir | N/A | chpst ^2^ | N/A | s6-envdir | envdir? | 
| | softlimit | softlimit | N/A | chpst ^2^ | N/A | s6-softlimit | softlimit? | 
| | setlock | setlock | N/A | chpst ^2^ | N/A | s6-setlock | setlock? | 
| *TAI64 Tools* |  |  |  |  |  |  |  |
| ---   | --- | --- | --- | --- | --- | --- | --- |
| | tai64n | tai64n | N/A | None | N/A | s6-tai64n | tai64n | 
| | tai64nlocal | tai64nlocal | N/A | None | N/A | s6-tai64nlocal | tai64nlocal | 
| *Logging* |  |  |  |  |  |  |  |
| ---   | --- | --- | --- | --- | --- | --- | --- |
| supervision tree log handling | readproctitle | readproctitle | N/A | "self-renaming" | N/A | N/A | N/A | 
| catch-all logger | N/A | N/A | N/A | N/A | N/A | s6-svscan-log | cyclog |
| logging tool | multilog | multilog | N/A | svlogd |  N/A | s6-log | cyclog? |
| |

Notes
1. the information is not available at this time, but will be added in the future.
2. when called using the name of the daemontools equivalent program, it changes its behavior to emulate that tool.
