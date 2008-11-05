SHELL := /bin/sh

LIBDIR := pyani-lib
PLTNAME := $(LIBDIR).plt

MZSCHEME := mzscheme
MZC := mzc
SETUP-PLT := setup-plt
SOURCES := $(wildcard $(LIBDIR)/*)
TESTS := $(LIBDIR)/tests.ss

define get-user-collects
$(shell mzscheme -e "(require setup/dirs) (display (path->string (find-user-collects-dir)))")
endef

.PHONY: all install clean

$(PLTNAME): $(SOURCES)
	$(MZC) --plt $@ --at-plt --plt-name "Pyani library" $(LIBDIR)

all: $(PLTNAME)

install: all
	$(NORMAL-INSTALL)
	$(SETUP-PLT) $(PLTNAME)

uninstall:
	$(NORMAL-UNINSTALL)
	@rm -frv $(call get-user-collects)/$(LIBDIR)

clean:
	@rm -frv `hg status --unknown --no-status`

test:
	$(MZSCHEME) $(TESTS)
