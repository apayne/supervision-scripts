## Features and Options

### User-Defined Services

This feature is meant for a system where a dedicated program, such as `usersv`, isn't available that 
allows users to join the supervision process tree and manage their own services.  It is done with a 
definition based on a specially-named template, which in turn will launch a sub-tree that can be 
controlled by that user.  Because the feature is script-based, it will lack certain feature, such as 
dynamic addition of users, but for most it will suffice.

To add a user, the administrator simply creates a new service definition with a special name, and then 
adds that definition to the system's `/service` directory.

The steps are:

1. `mkdir /etc/sv/(framework)-(user)`
2. `ln -s /etc/sv/.run/run-user-service /etc/sv/(framework)-(user)/run`
3. `ln -s /etc/sv/(framework)-(user) /service/`

Where:

* (framework) is one of `svscan` (daemontools), `runsvdir` (runit), or `s6-svscan` (s6).
* (user) is the user's name as it appears in `/home`.

Let's say I have a user `avery` that wants to have their own services, for whatever reason.  In my 
example, I'm running `s6` as my framework, so I do:

    mkdir /etc/sv/s6-svscan-avery
    ln -s /etc/sv/.run/run-user-service /etc/sv/s6-svscan-avery/run
    ln -s /etc/sv/s6-svscan-avery /service/

This will start `s6-svscan` on /home/avery/service and any service definitions in that directory will be 
brought up as well.  If I was running `runit` instead, the name would be `runsvdir-avery`, and for 
`daemontools` it would be `svscan-avery`.


### Dependency Resolution

This feature is meant as an option of last resort.  Enabling it should be considered carefully and with 
grave diligence.  Because of several requirements, the feature is not enabled by default.

Here is what you gain:

* Everything is already defined for you.  You don't need to lift a finger.
* Service A needs service B, service B will start before service A
* Service chain sequencing, where A needs B, and B needs C; C will start before B, and B before A
* Chains can be trees; you can have A start B and C, B start D and E, and C start F and G.
* "Tree" dependencies ending in the same leaf node will not have conflicts because if A eventually starts 
C, and B needs C as well, the script will check that C is active and bypass attempting to start it.
* Clear logging of failure modes due to issues with dependencies.  If A can't start because B won't, then 
A will complain about B's problems inside of A's log.

Here is what you lose:

* Enabling this feature on a system that has true dependency resolution will most assuredly break 
something.  You get to keep both pieces.
* It will only apply to services that start after it has been enabled.  It is not retroactive.
* You can no longer rename a service definition without renaming all of the links to `./needs` directories elsewhere.  Doing so will break dependency definitions.  I do not recommend this at all, and cannot support any issues surrounding this action.
* Dependency checks are done within the confines of `./check` definitions or the limits of the framework's `check` command; it is still possible for a service to respond with "up" but not be done initializing, so it really isn't "up" yet.  Therefore, the guarantee that B is really up before A is much, much weaker.  
* While highly not likely, it is possible to develop a race condition where services oscillate between up and down due to timing issues.  This should be very very rare, but I will warn you in advance.

So, in exchange for this convenience feature, you will have a policy decision set 
for you, you loose some choices, and some supervision guarantees may be much 
weaker.  It should only be used on systems that (a) do **not** already have 
dependency management and (b) in your use case, the desire to use the feature 
outweighs any costs. That being all said, you turn it on by doing this as `root` in 
a shell:

    echo 1 > /etc/sv/.env/NEEDS_ENABLED

Now you start your parent service, and the child service will bring itself up automatically before the 
parent starts.  That's it.  Scary, isn't it?

If needed, you can point ./run/run to an alternative launcher.  Note that this shifts the entire *system* 
to using that launcher; if you need per-service definitions shifted, simply override the setting for the 
service instead.


