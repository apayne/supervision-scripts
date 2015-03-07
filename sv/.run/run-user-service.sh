#!/bin/sh

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# A minimalist user-controlled service launch script.

# INSTALL FORMAT:
#   /service/(framework name)-(user name)
#
# REQUIREMENTS:
#  (framework name) is one of  "svscan", "rundirsv", or "s6-svscan".  No other options are valid
#  (user name) is a valid local account name without quotes, i.e. user name 'jdoe' for user "Jane Doe"
#
# EXAMPLES:
#
#   svscan-jdoe
#     Starts svscan from daemontools for control directory /home/jdoe/service
#
#   runsvdir-jdoe
#     Starts runsvdir from runit for control directory /home/jdoe/service
#
#   s6-svscan-jdoe
#     Starts s6-svscan from s6 for control directory /home/jdoe/service


# shunt all error logging to stdout
exec 2>&1


# to ensure that all of the standard commands
# of daemontools are supported, intercept the
# path and give our local copy priority.  All
# of the symlinks in .bin point to their
# equivalent in whatever framework is installed,
# ensuring correct behavior.

PATH=../.bin:$PATH


# determine the supervision scanning process along with the user name
SVINSTANCE=$( basename $( pwd ) )
SVKEY=$( echo $SVINSTANCE | sed 's/-/ /' | awk '{ print $1 }' )
SVUSER=$( echo $SVINSTANCE | sed 's/-/ /' | awk '{ print $2 }' )

# daemontools
[ $SVKEY='svscan' ] && SVSCAN=$SVKEY

# runit
[ $SVKEY='runsvdir' ] && SVSCAN=$SVKEY

# s6
# NOTE: the s6 naming convention uses hyphens so we need to re-assign $SVSCAN and $SVUSER
[ $SVKEY = 's6' ] && SVSCAN="s6-svscan" && SVUSER=$(echo $SVINSTANCE | sed 's/-/ /' | awk '{ print $3 }' )


# apply framework-specific options.
# SVOPTS is intentionally left undefined as we want the script
# to fail for a framework name that is not supported.

# daemontools: uses svscan, does not take arguments
[ $SVSCAN = 'svscan' ] && SVOPTS=""

# runit: uses runsvdir, takes a single process group argument
# NOTE: SVOPTS is conditional on the supervise directory being adjusted
# so that a failure in adjustment prevents launch (which would fail anyways)
[ $SVSCAN = 'runsvdir' ] && chmod 755 ./supervise && chown $SVUSER ./supervise/* && SVOPTS="-P"

# s6: uses s6-svscan, takes up to two arguments.
# NOTE: the maximum limit has been raised to 1000 processes to match the other frameworks
[ $SVSCAN = 's6-svscan' ] && SVOPTS="-c 1000"

# launch
exec setuidgid $SVUSER $SVSCAN $SVOPTS /home/$SVUSER/service
