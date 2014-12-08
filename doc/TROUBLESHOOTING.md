## Common Issues

### Definitions fail to start
* Is there an `untested` file present in the definition directory?  If so, the service you are attempting to start may not be fully tested.  If you see this, please send me details about your configuration and what you are attempting to start.
* Make sure you copied the four hidden directories to the service definition directory.

### Definitions loop over and over
This is typically the daemon/process exiting due to some error or configuration issue.  Check to make sure your service is installed correctly, and that any configuration files have the correct settings.

### My newly-created / manually-created simple service won't start
The requirements for run-simple are as follows:

1. The definition directory name must *exactly* match the program name.  Example: you want to start and control a program with the name `/usr/bin/mynewserviced`, so you would create your definition at `/etc/sv/mynewserviced`.
1. The `/etc/sv/(service)/run` file will be a symlink pointing to `../.run/run-simple`.
1. The `run-simple` script *assumes* you have a `/etc/sv/(service)/log` entry for logging but does not *require* it.
1. The program does not require the creation of directories, files, or file sockets.
1. The program does not depend on another service being already started, i.e. lightdm needs dbus to be running before it can run, so lightdm *cannot* be a simple service definition.
1. You have set all of the needed command line options in the ./options file,* including any flags that prevent backgrounding or daemonization of the program.*  This is critical to ensuring that the program will be properly controlled.
1. The ./options file is executable, i.e. 700 or 750 or 755.

The `run-simple` script has been tested extensively and if you follow these guidelines, your service should start easily.  If your new service conflicts with any requirement listed above, it will not start; you will need to use a different template or write the `run` file by hand, sorry.

### My getty won't start
The requirements for run-getty are as follows:

1. The appropriate getty is installed and in the `$PATH`
1. The definition directory name must be the getty program, a hyphen, and the tty to be controlled.  Example: mingetty-tty2 will start as `mingetty tty2`
1. The tty is *not* already controlled by another program, such as SysV's `/sbin/init` or systemd.  If the tty is already controlled, the script will fail to start, looping repeatedly until you either stop the script or disable the management of the tty from the other program.
1. Only `agetty`, `mingetty`, and `fgetty` are supported at this time; there is no support for a different getty.  If you need a new one added, please contact me.

### There is no getty log, why? -OR- I modified run-getty and now I can't log into a shell
I/O redirection, which is required for logging, would defeat the purpose of a getty, which interacts with both stdin and stdout.  A logging program would intercept output meant for the user and you will be effectively locked out.  *Attempting to shunt any I/O in the script is just asking for trouble*; please stick with the existing script (which has been tested for mingetty as of this writing) and the choices of `agetty`, `mingetty`, or `fgetty` as your tty control programs.

### My user-controlled svscan/runsvdir/s6-svscan won't start
The requirements for run-user-service are as follows:

1. Do not attempt to inject the command options for the service, they will be automatically included.
1. The appropriate svscan is installed and in the `$PATH`.  *This requirement may go away in a future version.*
1. The definition directory name must be the framework-specific svscan program, a hyphen, and the user name.  Example: s6-svscan-juser will start `sv6-svscan -c1000 /home/juser/service`.  Example 2: runsvdir-juser will start `runsvdir -P /home/juser/service`.

### My user-controlled svscan/runsvdir/s6-svscan can't be controlled, how do I fix this?
You need to run the control program under the same user account, and *specify the user's service directory*.  If you don't specify it, the control program will attempt to work with the *system's* svscan and it most likely will not be happy about that.
