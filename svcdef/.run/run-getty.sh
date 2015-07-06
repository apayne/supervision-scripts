#!/bin/sh

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# An environment-controlled getty launch script.
# Note that gettys run differently - they specify a tty to attach to.

# to ensure that all of the standard commands
# of daemontools are supported, intercept the
# path and give our local copy priority.  All
# of the symlinks in .bin point to their
# equivalent in whatever framework is installed,
# ensuring correct behavior.
PATH=../.bin:$PATH

# NOTE: all of the required parameters for the getty are now contained in ./env
exec envdir ../.env envdir ./env sh -c 'exec $PRELAUNCH $GETTY $GETTYOPTS $TTY $SECONDARYOPTS'
