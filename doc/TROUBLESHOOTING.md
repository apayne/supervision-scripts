## Common Issues

### Definitions fail to start
* Make sure you copied the four hidden directories to the service definition directory.
* Is there an `untested` file present in the definition directory?  If so, the service you are attempting to start may not be fully tested, and as such, may fail to start.  If you see this, please send me details about your configuration and what you are attempting to start.
* Is there an `broken` file present in the definition directory?  The service may not support supervision correctly, or may require additional configuration before launching.  Check the log of the service for details.
* Did you run the appropriate set-up script for your supervisor?  In `sv/.bin` you will see `use-daemontools`, `use-runit`, and `use-s6`.  As root, inside of the `sv/.bin` directory, run the corresponding script to set up your environment.  This will generate needed environment variables and symlinks.  If it hasn't been run, or you've run the wrong one, simply run the correct script and the settings will all reset.

### Definitions loop over and over
This is typically the daemon/process exiting due to some error or configuration issue.  Check to make sure your service is installed correctly, and that any configuration files have the correct settings.  The daemon may also require that another daemon be started first; look to see if there is a ./needs directory, and examine the names of the daemons contained therein.  Or, you can enable the optional dependency resolution to take care of that for you.

### My newly-created / manually-created simple service won't start
The requirements for run-sh are as follows:

1. The `svcdef/(service)/run` file will be a symlink pointing to `../.run/run`.  This is by design, so that you can change the default launcher to suit your needs.  It is not recommended that you link to `../.run/run-sh` directly unless you have specific requirements to use the shell-based launcher.
1. You must, at a minimum, define the values `DAEMON`, `DAEMONOPTS`, and `PRELAUNCH` in `sv/(service)/env/`.
1. If your daemon requires a run-state directory, you must define `sv/(service)/env/STATEDIR` to have the correct absolute path name.  You will also need, at a minimum, to define `sv/(service)/env/T_UID` to be the user name the daemon runs under, so it can access the directory.  Errors with the state directory are usually caused by the ownership not being set, and `T_UID` resolves that issue.
1. It is recommended, but not required, that you place a `pgrphack` statement in `sv/(service)/env/PRELAUNCH`.  This will assist in keeping the daemon tied to the supervisor.  The framework will automatically resolve `pgrphack` to use the correct program for your supervision arrangement.
1. The program does not require the creation of files, fifos, or file sockets.  If you have those specific needs, you're better off using a custom `(service)/run` script.
1. The program does not depend on another service being already started, i.e. lightdm needs dbus to be running before it can run, so lightdm *cannot* be a simple service definition.  You can overcome this by enabling dependency resolution, but there are limits.
1. You have set all of the needed command line options in the ./env directory,* including any flags that prevent backgrounding or daemonization of the program.*  This is critical to ensuring that the program will be properly controlled.

The `run-sh` script has been tested extensively and if you follow these guidelines, your service should start easily.  If your new service conflicts with any requirement listed above, it will not start; you will need to use a different template or write the `run` file by hand, sorry.

### My getty won't start
The requirements for run-getty are as follows:

1. The appropriate getty is installed and in the `$PATH`
1. The tty is *not* already controlled by another program, such as SysV's `/sbin/init` or systemd.  If the tty is already controlled, the script will fail to start, looping repeatedly until you either stop the script or disable the management of the tty from the other program.
1. Only `agetty`, `mingetty`, and `fgetty` are supported at this time; there is no support for a different getty.  If you need a new one added, please contact me.

### There is no getty log, why? -OR- I modified run-getty and now I can't log into a shell
I/O redirection, which is required for logging, would defeat the purpose of a getty, which interacts with both stdin and stdout.  A logging program would intercept output meant for the user and you will be effectively locked out.  *Attempting to shunt any I/O in the script is just asking for trouble*; please stick with the existing script (which has been tested for mingetty as of this writing) and the choices of `agetty`, `mingetty`, or `fgetty` as your tty control programs.

### My user-controlled svscan/runsvdir/s6-svscan won't start
The requirements for run-user-service are as follows:

1. Do not attempt to inject the command options for the service, they will be automatically included.
1. The appropriate svscan is installed and in the `$PATH`.
1. The definition directory name must be the framework-specific svscan program, a hyphen, and the user name.  Example: s6-svscan-juser will start `sv6-svscan -c1000 /home/juser/service`.  Example 2: runsvdir-juser will start `runsvdir -P /home/juser/service`.

### My user-controlled svscan/runsvdir/s6-svscan can't be controlled, how do I fix this?
You need to run the control program under the same user account, and *specify the user's service directory*.  If you don't specify it, the control program will attempt to work with the *system's* svscan and it most likely will not be happy about that.
