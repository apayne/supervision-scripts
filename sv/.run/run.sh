#!/bin/sh

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# redirect stderr to stdout...
exec 2>&1


# shim our support tools into the path relative to the definition
PATH=$PWD/../.bin:$PATH


# check for a broken definition marker, and abort processing
# if present with a message in the daemon's log.
if test -f ./broken ; then
  cat ./broken
  exit 1
fi


# figure out our definition name, which is needed for service control
SELF=$(basename $(pwd))


# prepare command phrases
DO_UP=$(cat ../.env/TOOLCMD ; echo -n " " ; cat ../.env/CMDUP)
DO_CHECK=$(cat ../.env/TOOLCHECK ; echo -n " " ; cat ../.env/CMDCHECK)


# first determine if dependencies are enabled.  If not, skip
# dependency startup altogether.  By default, it is not enabled.
# Note that this is the default "by design" behavior of the frameworks.
if test $( cat ../.env/NEEDS_ENABLED ) -gt 0; then
  # probe for a needs directory, and attempt to start each link
  # found if present; if the needed definition can't start or isn't found, halt the script.
  if test -d ./needs ; then
    cd ./needs
    # make sure the directory isn't empty
    if test $(ls | wc -l) -gt 0 ; then
      echo -n "$SELF: needs "
      for SVCITER in ./* ; do
        SVCNAME=$(basename $SVCITER)
        # probe each symlink via dereference to make sure that
        # the directory really exists, as it is possible for
        # the ./needs to be present but no entry present in /service
        if test -h $SVCITER ; then
          echo -n "$SVCNAME, "
          $DO_UP $SVCNAME
          if test $? -eq 0 ; then
            $DO_CHECK $SVCNAME
            if test $? -gt 0 ; then
              # a needed dependency failed, write the error out
              echo "$SVCNAME failed to start, aborting."
              exit 1
            else
             echo "$SVCNAME up."
            fi
          else
            echo "$SVCNAME did not come up successfully, aborting."
            exit 1
          fi
        else
          # if needs are enabled but not defined in /service
          # then abort
          echo "$SVCNAME s not defined in the service directory, aborting."
          exit 1
        fi
      done
    else
      # hint that an empty ./needs directory may need clean-up
      echo "$SELF has needs but none are found, skipping dependency check."
    fi

    cd ..

  fi

fi


# look for a user ID and store it if found
T_UID=""
if test -f ./env/T_UID ; then
  T_UID=$( cat ./env/T_UID )
fi


# look for a group ID and store it if found
T_GID=""
if test -f ./env/T_GID ; then
  T_GID=$( cat ./env/T_GID )
fi


# if a run-state directory is defined, then build it prior to launch
if test -f ./env/STATEDIR ; then
  RUNSTATEDIR=$( cat ./env/STATEDIR )
  mkdir -p $RUNSTATEDIR
  chmod 755 $RUNSTATEDIR
  if test ! -z $T_UID ; then
    chown $T_UID $RUNSTATEDIR
  fi
  if test ! -z $T_GID ; then
    chgrp $T_GID $RUNSTATEDIR
    # make write access available to the group if it was defined
    chmod 775 $RUNSTATEDIR
  fi
fi


# the system default environment is defined in ../.env,
# $DAEMON, $DAEMONOPTS and $PRELAUNCH are defined in the local ./env diretory
exec envdir ../.env envdir ./env sh -c 'exec $PRELAUNCH $DAEMON $DAEMONOPTS'
