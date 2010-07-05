SHELL := /bin/sh

LIBDIR := pyani-lib
PLTNAME := $(LIBDIR).plt

SCHEME := mzscheme
PACK-PLT := raco pack
SETUP-PLT := raco setup
SOURCES := $(wildcard $(LIBDIR)/*)
TESTFILE := $(LIBDIR)/tests.ss

define get-user-collects
$(shell $(SCHEME) -e "(require setup/dirs) (display (path->string (find-user-collects-dir)))")
endef

.PHONY: all install uninstall clean check

$(PLTNAME): $(SOURCES)
	$(PACK-PLT) --at-plt --plt-name "Pyani library" $@ $(LIBDIR)

all: $(PLTNAME)

install: all
	$(NORMAL-INSTALL)
	$(SETUP-PLT) $(PLTNAME)

uninstall:
	$(NORMAL-UNINSTALL)
	@rm -frv $(call get-user-collects)/$(LIBDIR)

clean:
	@rm -frv `hg status --unknown --no-status`

check:
	@$(SCHEME) $(TESTFILE) | sed -e 's/: */:/'
