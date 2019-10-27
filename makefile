NAME = supervision-scripts
SHELL = /bin/bash
INSTALL = /usr/bin/install
MSGFMT = /usr/bin/msgfmt
SED = /bin/sed
DESTDIR =
BINDIR = /usr/bin
DOCDIR = /usr/share/doc/$(NAME)
SRVDIR = /etc/svcdef

# for config
SUPERVISOR = none
LOGGER = none
ENABLE_NEEDS = no

all:

install: all
	$(INSTALL) -d $(DESTDIR)$(DOCDIR)
	$(INSTALL) -d $(DESTDIR)$(SRVDIR)
	$(INSTALL) -D -m 0644 LICENSE.md "$(DESTDIR)$(DOCDIR)/LICENSE.md"
	$(INSTALL) -D -m 0644 README.md "$(DESTDIR)$(DOCDIR)/README.md"
	for doc in FEATURES.md TROUBLESHOOTING.md ; do \
		$(INSTALL) -D -m 0644 doc/$$doc "$(DESTDIR)$(DOCDIR)/$$doc" ; \
	done
	for dir in svcdef/* svcdef/.[!.]* ; do \
		cp -Ra "$$dir" "$(DESTDIR)$(SRVDIR)/" ; \
	done

config:
	# set supervision framework
	cd $(DESTDIR)$(SRVDIR)/.bin ; \
	if [ $(SUPERVISOR) = daemontools ]; then \
		./use-daemontools ; \
	elif [ $(SUPERVISOR) = runit ]; then \
		./use-runit ; \
	elif [ $(SUPERVISOR) = s6 ]; then \
		./use-s6 ; \
	fi
	# set logging service
	cd $(DESTDIR)$(SRVDIR)/.log ; \
	if [ $(LOGGER) = multilog ]; then \
		rm run ; \
		ln -s ./run-multilog run ; \
	elif [ $(LOGGER) = svlogd ]; then \
		rm run ; \
		ln -s ./run-svlogd run ; \
	elif  [ $(LOGGER) = s6-log ]; then \
		rm run ; \
		ln -s ./run-s6-log run ; \
	fi
	# set dependency switch
	if [ $(ENABLE_NEEDS) = yes ]; then \
		echo 1 > "$(DESTDIR)$(SRVDIR)/.env/NEEDS_ENABLED" ; \
	fi

check:
	cd $(DESTDIR)$(SRVDIR)/.bin ; \
	./show-settings

uninstall:
	rm -r $(DESTDIR)$(DOCDIR)
