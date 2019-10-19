NAME = supervision-scripts
SHELL = /bin/bash
INSTALL = /usr/bin/install
MSGFMT = /usr/bin/msgfmt
SED = /bin/sed
DESTDIR =
BINDIR = /usr/bin
DOCDIR = /usr/share/doc/$(NAME)
SRVDIR = /etc/svcdef

all:

install: all
	$(INSTALL) -d $(DESTDIR)$(DOCDIR)
	$(INSTALL) -d $(DESTDIR)$(SRVDIR)
	$(INSTALL) -D -m 0644 doc/LICENSE "$(DESTDIR)$(DOCDIR)/LICENSE"
	$(INSTALL) -D -m 0644 README.md "$(DESTDIR)$(DOCDIR)/README.md"
	for doc in FEATURES.md TROUBLESHOOTING.md; do \
		$(INSTALL) -D -m 0644 doc/$$doc "$(DESTDIR)$(DOCDIR)/$$doc"; \
	done
	for dir in svcdef/* svcdef/.[!.]*; do \
		cp -Ra "$$dir" "$(DESTDIR)$(SRVDIR)/"; \
	done

uninstall:
	rm -r $(DESTDIR)$(DOCDIR)
