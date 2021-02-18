.POSIX:
.SUFFIXES:
.PHONY: all install

DIR = .
PREFIX = /usr/local
_VERSION = 0.11.0

# use make -e
CXX = c++
CXXFLAGS =
LDFLAGS =
INCS =
LIBS =

# these should be changed from CLI if required
_CXXSTD = -std=c++11
_CXXFLAGS = -fpie
_LDFLAGS = -pie
_INCS = -I . -I '$(DIR)/include' -I '$(DIR)/subprojects/libdasynq/include'
_LIBS =

# rules
_COMPILE = '$(CXX)' $(_CXXSTD) -c $(_CXXFLAGS) $(CXXFLAGS)
_LINK = '$(CXX)' $(_LDFLAGS) $(LDFLAGS)

all: dinit dinitctl dinitcheck shutdown

mconfig.h:
	 >'$@' echo '#pragma once'
	>>'$@' echo 'constexpr static char DINIT_VERSION[] = "$(_VERSION)";'
	>>'$@' echo 'constexpr static char SYSCONTROLSOCKET[] = "/run/dinitctl";'
	>>'$@' echo 'constexpr static char SBINDIR[] = "$(PREFIX)/sbin";'
	>>'$@' echo 'constexpr static char SHUTDOWN_PREFIX[] = "";'

dinit.o: mconfig.h
	exec $(_COMPILE) -o $@ '$(DIR)/src/dinit.cc' $(_INCS) $(INCS)
load-service.o: mconfig.h
	exec $(_COMPILE) -o $@ '$(DIR)/src/load-service.cc' $(_INCS) $(INCS)
service.o: mconfig.h
	exec $(_COMPILE) -o $@ '$(DIR)/src/service.cc' $(_INCS) $(INCS)
proc-service.o: mconfig.h
	exec $(_COMPILE) -o $@ '$(DIR)/src/proc-service.cc' $(_INCS) $(INCS)
baseproc-service.o: mconfig.h
	exec $(_COMPILE) -o $@ '$(DIR)/src/baseproc-service.cc' $(_INCS) $(INCS)
control.o: mconfig.h
	exec $(_COMPILE) -o $@ '$(DIR)/src/control.cc' $(_INCS) $(INCS)
dinit-log.o: mconfig.h
	exec $(_COMPILE) -o $@ '$(DIR)/src/dinit-log.cc' $(_INCS) $(INCS)
dinit-main.o:
	exec $(_COMPILE) -o $@ '$(DIR)/src/dinit-main.cc' $(_INCS) $(INCS)
run-child-proc.o: mconfig.h
	exec $(_COMPILE) -o $@ '$(DIR)/src/run-child-proc.cc' $(_INCS) $(INCS)
options-processing.o:
	exec $(_COMPILE) -o $@ '$(DIR)/src/options-processing.cc' $(_INCS) $(INCS)

dinit: dinit.o load-service.o service.o proc-service.o baseproc-service.o control.o dinit-log.o dinit-main.o run-child-proc.o options-processing.o
	exec $(_LINK) -o $@ $? $(_LIBS) $(LIBS)

dinitctl.o: mconfig.h
	exec $(_COMPILE) -o $@ '$(DIR)/src/dinitctl.cc' $(_INCS) $(INCS)

dinitctl: dinitctl.o
	exec $(_LINK) -o $@ $? $(_LIBS) $(LIBS)

dinitcheck.o: mconfig.h
	exec $(_COMPILE) -o $@ '$(DIR)/src/dinitcheck.cc' $(_INCS) $(INCS)

dinitcheck: dinitcheck.o options-processing.o
	exec $(_LINK) -o $@ $? $(_LIBS) $(LIBS)

shutdown.o: mconfig.h
	exec $(_COMPILE) -o $@ '$(DIR)/src/shutdown.cc' $(_INCS) $(INCS)

shutdown: shutdown.o
	exec $(_LINK) -o $@ $? $(_LIBS) $(LIBS)

install: all
	mkdir -p -- '$(DESTDIR)$(PREFIX)/sbin'
	cp -- dinit dinitctl dinitcheck shutdown '$(DESTDIR)$(PREFIX)/sbin'
