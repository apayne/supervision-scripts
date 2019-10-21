#!/bin/sh

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# A minimalist user-controlled service launch script.

# INSTALL FORMAT:
#   /service/(framework name)-(user name)
#
# REQUIREMENTS:
#  (framework name) is one of  "svscan", "runsvdir", or "s6-svscan".  No other options are valid
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
SVINSTANCE=$( basename $PWD )

case $SVINSTANCE in
# daemontools: uses svscan, does not take arguments
svscan-*)
	SVUSER=$( echo $SVINSTANCE | cut -d "-" -f 2 )
	SVSCAN="svscan"
	SVOPTS=""
	:;;
# runit: uses runsvdir, takes a single process group argument
runsvdir-*)
	SVUSER=$( echo $SVINSTANCE | cut -d "-" -f 2 )
	SVSCAN="runsvdir"
	# NOTE: failure in adjustment prevents launch
	chmod 755 ./supervise && chown $SVUSER ./supervise/* || exit 1
	SVOPTS="-P"
	:;;
# s6: uses s6-svscan, takes up to two arguments.
s6-svscan-*)
	SVUSER=$( echo $SVINSTANCE | cut -d "-" -f 3 )
	SVSCAN="s6-svscan"
	# NOTE: the maximum limit has been raised to 1000 processes to match the other frameworks
	SVOPTS="-c 1000"
	:;;
*)
	# unrecognized framework
	exit 1
esac

# launch
exec setuidgid $SVUSER $SVSCAN $SVOPTS /home/$SVUSER/service
