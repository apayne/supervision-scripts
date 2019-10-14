## Conventions

* When you see text in *italics*, I'm talking about a name or concept.

* When you see text in **bold**, it means that I made a rule that needs to be followed, a design decision, or a fairly safe assumption.

* When you see text in a `Cartouche`, it means that I'm talking about a file name.

* When you see a dot-slash in front of a `./Cartouche`, it means I'm talking about a file name "in the current directory".

* When you see a dot-dot-slash in front of a `../Cartouche`, it means I'm talking about a file name "in the parent directory of the directory where we are at".

* When you see `file -> file` I'm talking about a soft-link.  For the sake of brevity, I will also call these *symlinks*.

```
#!shell

When you see text in a Cartouche that expands to the full width of the page,
that would be a command to be typed in a command line, or
the output of a command.
```

#### Before Proceeding

Supervision-scripts uses a lot of relative pathing and softlinks, aka symlinks, to support how it works.  If you're not familiar with these concepts, you'll want to read up on them before digging deeper into this document.


## Introduction 

How did templates become what they are?  Why are there a bunch of hidden directories?  How is it even possible to support all those frameworks with just a single set of definitions?  Why can't I just use .service files?  Let's answer these questions and more.

First, we'll start with an assumption:

* **Most supervision frameworks use the same layout and conventions for starting processes.**

Sounds easy enough.  I call such a layout a *process definition*.  Let's go on to look at what a *process definition* is.

## Process Definitions

A process definition has several parts, some required, some optional.  It consists of:

* A directory where the definition resides.
* A `run` file, typically a script, that starts a long-lived process, called a *daemon*.
* An optional `./log` directory inside of the definition directory, used to indicate that logging is desired for the daemon process.
* If the `log` directory is present, a `run` file inside of it that will start a logging process that will be used to capture log data from the daemon.  The path for the file would be `./log/run`.

### Minimum Requirements
The bare minimum of a process definition that would start a daemon process is a named directory with a file in it named `./run`, which is itself a program or script that will start the process to be supervised.  It looks something like this:

    /etc/sv/servicename/
    /etc/sv/servicename/run

In the above directory listing,

1. `/etc/sv/` is where service definitions are installed.  *They don't need to be named that*, it could be named `/var/sv` or `/var/definitions` or `/foo/bar` for all we care.  I'm just using it out of habit.

2. `servicename` is typically the name of the process to be launched.  Again, *it doesn't have to be named that*, we could have named it `baz` and the full path would be `/etc/sv/baz`, or `/var/sv/baz`, or even `/foo/bar/baz`, any of which would still work.  It would however make you scratch your head as to what process is defined in `baz`, so for the sake of keeping things sane, try to keep your service directory names the same as the process name.  This is typically the convention used by most installations, so most people are familiar with it.

3. `run` is the actual program that will be run when supervision starts for that process.  It can be a program or script.  Typically `run` is a script written in a shell language, so it is common to hear people talking about *run scripts*, and they are actually referring to this specific file.

4. You'll notice that the live definitions live in `/etc/sv` and not `/etc/svcdef`.  That's because system managment programs may wish to keep the definition separate from the live system.  This is fine.  Also, if you are really desperate and need to bring services up in an emergency, you can manually copy the definitions from `/etc/svcdef` to `/etc/sv`, or even link directly to `/etc/svcdef` itself (although I don't recommend this).

When your supervision framework starts up, and wishes to start the process defined at `/etc/sv/servicename` it will spawn a *supervisor* process that in turn will attempt to run the program located at `/etc/sv/servicename/run`.  The run script will handle the setup needed to get the process running, and typically it will then replace itself with the actual process, and the process will attach to the supervisor.  At this point, the run script is gone, the process is running, and the supervisor is the parent of the launched process.

### Writing Individual Runscripts is Error-Prone

So now we have a simple way to deal with defining and launching a long-lived process, typically called a *daemon*, and a means of watching over it should it crash or terminate early.  You can write up all kinds of definitions for different daemons and have supervised processes everywhere.  Except... there's a lot of one-off stuff in each script.  And each time we write a script, it's subject to typos, and by extension, bugs, that will cause some headaches.  If only there was a way to write the script once, so it is debugged and ready, and re-use the script to launch all of our processes.  So, the idea of a *template script* was born.

### The Template Script Concept

Template scripts are at the heart of supervision-scripts.  With the template script, I define a few settings, point the process definition to my template script, and the script does the rest.  Now I worry less about re-typing scripts and more about getting the settings for the daemon process right the first time.

I could copy the template to each process definition directory, but that would require a lot of effort.  Every time the template script was updated, each definition would need to receive a new copy.  Plus, it may require a bit more storage.  To get around this, **a single `run` script is written, and in each definition directory, a symlink to the script is inserted**.  That way, **as I update the script, every definition would immediately receive the latest update as well**.  But where to put this script?  Because I need to share the same script outside of each definition directory, **I will use a relative path name to find the script in the parent directory, as it is a fairly safe assumption that the definitions will live at the same location**.  If I put it in with the rest of the definition directories, it will be out of place.  But I also need it to be nearby, so that I can use relative pathing with my symlinks.  Creating a regular directory to hold scripts makes sense, but anyone looking at the directory would initially be confused by seeing it mixed in with the definitions - the same problem as having the script just "floating around" the definitions.  So, it makes some sense that **I will hide the directory among the definitions, so it is nearby, but not mixed into directory listings**.  That directory is named `.bin` and lives in the same directory as the definitions.  Notice the dot on the beginning of the directory name, which means "please hide me when looking at this directory".

### How Templates Are Used

Our listing now looks like this:

    /etc/sv/.bin
    /etc/sv/.bin/run.sh
    /etc/sv/servicename/
    /etc/sv/servicename/run -> ../.bin/run.sh

You can always get a directory listing of the hidden `.bin` directory with


```
#!shell

ls /etc/sv/.bin
```


...and see what is inside of it.  Cool.  This works.  We can now add definitions with uniform scripts, get a listing of the service definitions without clutter, and still see the scripts when we need to.

### Supporting Other Run Templates

While our `/etc/sv/.bin/run.sh` file is a shell script, we don't necessarily need to use a shell to launch all of this.  Maybe we have something that does the launch for us, a dedicated program like execline or nosh, that does this.  But our scripts are tied to `/etc/sv/.bin/run.sh` which is a shell script, so that becomes a problem.  It would be nice if we could simply switch environments by changing whatever `/etc/sv/servicename/run` points at.  So, **we will use a 2nd symlink in `.bin` that points to the correct run file to be used by the supervision program.**  Switching your run scripts to something else - anything else - is as simple as changing a single file.  Now our directory listing looks like this:

    /etc/sv/.bin
    /etc/sv/.bin/run -> ./run.sh
    /etc/sv/.bin/run.sh
    /etc/sv/servicename/
    /etc/sv/servicename/run -> ../.bin/run


There's something still missing: the settings.  Where do we get those?

### Settings

Most hand-written `./run` scripts have their settings embedded in them directly.  Changing a setting means changing the script, and for one or two of them, this isn't an issue.  But we aren't using individual run scripts per-daemon, we are instead sharing the same script for all daemons.  This is a problem, because we can't just encode the settings into this single script.  Well, we could, but it would be a massive mess of CASE statements or IF-THEN-ELSE.  It would be a nightmare to maintain.  It would be easier if we could store the settings somewhere and "read" them into the script.

At first, I did this by having a separate shell script file that contained all the settings, and this worked just fine.  Right up to the point when I decided that I might want to support more than just shell scripts.  Then I had two problems, instead of just one.  I needed a way to save settings that was universal and easy.  After looking around, I settled on using `envdir` as a means of storage for settings.

### Using `envdir` for settings

The `envdir` program is present in nearly all of the supervisor frameworks, and for those where it isn't, it can be easily emulated or supported.  The program takes a single argument, a directory name, and then moves through each file in that directory.  Whatever the name of that file is, becomes the name of the variable in a shell; and whatever was the content of that file becomes the value of that variable.  This variable name definition is *scoped*, so it only has meaning while the program is running.  The first question that comes to mind is "how is that useful?".  The answer is, because envdir will *chain load* a program with those variables set.

### Chain Loading

*Chain Loading* sounds complicated, but is easy to understand.  When a program *chain loads*, it performs some function, and then replaces itself with another program after it is done with that function.  A chain loading program looks like this:

    envdir ./env someprogram

In this case, the `envdir` program will read the contents of ./env, set the appropriate variables, launch `someprogram` and then replace itself with `someprogram`.  We can even string together chain loaders.  A more advanced example:

    envdir ../.env envdir ./env someprogram

In this example, settings are loaded from `../.env` first, then a 2nd `envdir` is run loading settings from `./env` second, and finally `someprogram` is run.  This is an important concept as **chainloading is used in conjunction with `envdir` to create a portable environment**.

### System-Wide Default Settings

The locations of files for Linux is not the same as the location of files in FreeBSD, or AIX, or Solaris, or any other distribution.  Also, the file path that is searched when looking for programs can be different as well.  We need a way to define system-wide settings that can be adapted to the installation.

To do this, a single `.env` directory will be created and the settings stored inside of it in `envdir` format.  The template script on start-up will then read the settings from this directory and set up the appropriate environment for our daemon, includes the `$PATH` variable.

Our directory listing now looks like this:

    /etc/sv/.bin
    /etc/sv/.bin/run -> ./run.sh
    /etc/sv/.bin/run.sh
    /etc/sv/.env/PATH
    /etc/sv/servicename/
    /etc/sv/servicename/run -> ../.bin/run

When the template `./run` script starts, it will use the `PATH` as defined in `sv/.env/PATH`.  Switching the path for the entire system is as simple as switching the contents of `sv/.env/PATH` to whatever you like.

### Daemon-Specific Settings

We'll need the name of the program that is being launched.  We'll also need any command line *options* that go with the command.  And finally, we will need any programs that are part of a *chain loader*.  So that's three variables.  We'll call them `./envdir/DAEMON` for the program, `./envdir/DAEMONOPTS` for the options that go with the program, and `./envdir/PRELAUNCH` for the chain loader.

Our directory listing now looks like this:

    /etc/sv/.bin
    /etc/sv/.bin/run.sh
    /etc/sv/.env/PATH
    /etc/sv/env/DAEMON
    /etc/sv/env/DAEMONOPTS
    /etc/sv/env/PRELAUNCH
    /etc/sv/servicename/
    /etc/sv/servicename/run -> ../.bin/run.sh

When the `run.sh` script is run, it will first load the system-wide settings, then the daemon-specific settings, and finally launch the appropriate daemon.  Note that we can easily override the system settings by simply specifying a new setting in the daemon's individual `./env` directory.  For instance, while `/etc/sv/.env/PATH` will have a fairly sane file path in it, we may want to specifically override it with `/etc/sv/servicename/env/PATH` which will make it "forget" the system-wide PATH variable and load a new one.


### Setting up a definition

Now that we know the basic layout, we can create a definition and hook it into our arrangement with just a minimal amount of work.  We'll assume that the static definitions live at `/etc/svcdef`, that the run-time definitions live at `/etc/sv`, and that `/service` holds a list of daemons that we want to run.

Let's say we have a new daemon, "foobaz", that intercepts network packets, scrubs them, and sends them back out shiny.  The foobaz service is all the rage and everyone wants their packets to be sparkly-clean, so you download and build foobaz, and install it locally.  Great, you're halfway there to lemony-fresh packets!  But how do you hook this into your system when it's running a supervisor?

First, you need to create the definition.  The default definitions live in the /etc/svcdef directory and are named after the daemon they manage.  We can call it anything we like, but **it's easier if the directory name matched the daemon name, so you can see at a glance what directory manages what daemon.**  So let's start by making our directories as `root`:

    sudo su - root
    mkdir /etc/svcdef/foobaz
    cd /etc/svcdef/foobaz
    mkdir ./log

This is version 0.9 of foobaz.  It's possible that the 1.0 release may have different command switches.  So let's set up a versioned environment for it.

    mkdir ./version
    mkdir ./version/0.9
    mkdir ./version/1.0

We'll activate the 0.9 version as the version we are running.  When the 1.0 release comes out, we'll simply reset it to point to `./version/1.0` instead.

    ln -s ./version/0.9 ./env

Alright, now let's add the links to the template scripts to get `./run` and `./log/run` working.

    ln -s ../.bin/run ./run
    cd ./log
    ln -s ../../.log/run ./run
    cd ..

We're using relative pathing in all cases because this is how we can find our templates, which live wherever the definitions live.  Notice how we had to use two `..` entries for the log run file, because the directory was deeper.

Now all we need is to define the program, its options, and any chainloading programs that are needed to launch it.  Let's start with the daemon.

    echo "foobaz" > ./version/0.9/DAEMON

This installation is special; it already has the widget2.0 service running, and you really, really want the cool foobaz-to-widget bridge to work because you compiled foobaz with that option.  To activate it, you need to include the command option `--enable-widget2` when the foobaz daemon starts.  So let's add that option to the daemon's command line:

    echo "--enable-widget2" > ./version/0.9/DAEMONOPTS

Also, we just noticed in the documentation that foobaz tends to not be well-behaved.  As we suspect it may try to detach from its parent process, let's place a little insurance into the chainload definition to keep that from happening.

    echo "pgrphack" > ./version/0.9/PRELAUNCH

Our definition appears complete, let's make it available for live use.

    cp -Rav /etc/svcdef/foobaz /etc/sv/

Now let's activate it.

    ln -s /etc/sv/foobaz /service

We check the output of `ps`, and we see it's running.  Cool!  We created the definition, installed it, and started it.  Let's look at the logs.

    ls /var/log/foobaz

When the logger for foobaz starts, it automatically creates a matching directory name in /var/log, and sends log files there.

#### A Summary of Assumptions, Decisions, and Rules

* Most supervision frameworks use the same layout and conventions for starting processes.
* a single `run` script will be used as a template, and in each definition directory, a symlink to the script is inserted
* because there is only one script, as I update it, every definition will immediately receive the latest update as well
* I will use a relative path name to find the script in the parent directory, as it is a fairly safe assumption that the definitions will live at the same location
* I will hide the directory among the definitions, so it is nearby, but not mixed into directory listings, so that when I look at the directory, I can clearly separate the definitions from the support directories.
* I will use chainloading in conjunction with `envdir` to create a portable environment, so that regardless of the template used, the environment variables can be set.
* we will use a 2nd symlink in `.bin` that points to the correct run file to be used by the supervision program, allowing the template script to be changed as needed (i.e. execline, nosh)
* it's easier if the definition name matches the daemon name, so you can see at a glance what directory manages what daemon.
