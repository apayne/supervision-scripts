# This is called for peer-level dependency launches.  It is active when NEEDS_ENABLED=1

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

