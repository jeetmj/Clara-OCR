#
#  Copyright (C) 1999-2002 Ricardo Ueda Karpischek
#
#  This is free software; you can redistribute it and/or modify
#  it under the terms of the version 2 of the GNU General Public
#  License as published by the Free Software Foundation.
#
#  This software is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this software; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307,
#  USA.
#

#
# Clara OCR version number.
#
VERSION=20031214;

#
# CONFIGURATION SECTION - BEGIN
#

#
# Configure the destination directories:
#
#BINDIR=/usr/local/bin
BINDIR=$(DESTDIR)/usr/bin

#MANDIR=/usr/local/man/man1
MANDIR=$(DESTDIR)/usr/share/man/man1

#DOCDIR=/usr/local/doc/clara
#DOCDIR=/usr/doc/clara
#DOCDIR=/usr/doc/clara-$(VERSION)
DOCDIR=$(DESTDIR)/usr/share/doc/clara

#
# Configure these variables accordingly to your system:
#
CC = gcc

HUSH=./hush

#
# Now choose the Clara OCR compilation options:
#
#   HAVE_POPEN  .. If defined, Clara OCR will include code to
#                  compress/uncompress gzipped files on the
#                  fly using pipes (Clara OCR does not support
#                  zlib). Undefine on systems that don't
#                  support popen.
#
#   MEMCHECK    .. If defined, Clara OCR will include
#                  code to detect memory leaks in some
#                  critical points. Undefine for maximum
#                  speed.
#
#   FUN_CODES   .. If defined, Clara OCR will include fun
#                  features to be used in presentations. If
#                  defined, then HAVE_SIGNAL must be defined
#                  too.
#
#   HAVE_SIGNAL .. If defined, Clara OCR will include code
#                  to install signal handlers on startup
#                  (important).
#
#   PATT_SKEL   .. Instead of using global skeleton parameters,
#                  use per-pattern skeleton parameters. This is
#                  an experimental feature, and chances are that
#                  it will be completely removed in the near future.
#
#   CF          .. Hacks for tests using Candido de Figueiredo
#                  Dictionary (please do not define this macro).
#
#   TEST        .. Include test code.
#
#   NO_RINTF    .. required on systems that do not provide rintf
#                  (like Solaris).
#
COPTS = -DHAVE_POPEN -DMEMCHECK -DFUN_CODES -DHAVE_SIGNAL -DTEST -DNO_RINTF
#COPTS = -DHAVE_POPEN -DMEMCHECK

#
# Add or remove flags if necessary:
#
CFLAGS = -g -Wall $(COPTS) -O0 -Werror
#CFLAGS = -g -Wall $(COPTS) -O3 -march=native -ffast-math -mfused-madd
#CFLAGS = $(INCLUDE) -g -Wall -pedantic $(COPTS)
#CFLAGS = $(INCLUDE) -g -O2 -Wall $(COPTS)
#CFLAGS = $(INCLUDE) -g -O2 -pedantic $(COPTS)
#CFLAGS = $(INCLUDE) -g -O2 $(COPTS)

PKG_CONFIG_PKGS = gtk+-2.0 webkit-1.0 imlib2

CFLAGS += $(shell pkg-config --cflags $(PKG_CONFIG_PKGS) )

#
# Add or remove flags if necessary:
#
LDFLAGS = -g -rdynamic
LDFLAGS += $(shell pkg-config --libs $(PKG_CONFIG_PKGS) )
#
# If your system requires additional libs, please add them:
#
LINKLIB = -lm

#
# CONFIGURATION SECTION - END
#

DFLAGS = -web

OBJS = clara_marshalers.o \
       clara.o skel.o event.o symbol.o pattern.o pbm2cl.o cml.o\
       welcome.o util.o alphabet.o revision.o build.o\
       consist.o pgmblock.o preproc.o obd.o html.o redraw.o docView.o
# removed: html.o redraw.o

SOURCES = $(OBJS:%.o=%.c)
DOCSRC = book.c $(SOURCES)

all: TAGS clara

-include $(SOURCES:%.c=.deps/%.d)

#
# The programs.
#

clara: $(OBJS) | hush
	@$(HUSH) "Linking $@" $(CC) -o clara $(LDFLAGS) $(OBJS) $(LINKLIB)

manager: manager.c
	$(CC) $(CFLAGS) -o manager manager.c

#
# Documentation targets.
#

adv.new:
	rm -f doc/clara-book.html doc/clara-book.1

adv: adv.new
	./mkdoc.pl $(DFLAGS) -html -book $(DOCSRC) *.h >doc/clara-adv.html
	./mkdoc.pl $(DFLAGS) -nroff -book $(DOCSRC) *.h >doc/clara-adv.1

dev.new:
	rm -f doc/clara-dev.html doc/clara-dev.1

dev: dev.new
	./mkdoc.pl $(DFLAGS) -html -devel $(DOCSRC) *.h >doc/clara-dev.html
	./mkdoc.pl $(DFLAGS) -nroff -devel $(DOCSRC) *.h >doc/clara-dev.1

tut.new:
	rm -f doc/clara-tut.html doc/clara.1

tut: tut.new
	./mkdoc.pl $(DFLAGS) -html -tutorial $(DOCSRC) *.h >doc/clara-tut.html
	./mkdoc.pl $(DFLAGS) -nroff -tutorial $(DOCSRC) *.h >doc/clara.1

faq.new:
	rm -f doc/clara-faq.html doc/clara-faq.1

faq: faq.new
	./mkdoc.pl $(DFLAGS) -html -faq $(DOCSRC) *.h >doc/clara-faq.html
	./mkdoc.pl -faq $(DOCSRC) *.h >doc/FAQ

glossary.new:
	rm -f doc/clara-glo.html doc/clara-glo.1

glossary: glossary.new
	./mkdoc.pl $(DFLAGS) -html -glossary $(DOCSRC) *.h >doc/clara-glo.html
	./mkdoc.pl -glossary $(DOCSRC) *.h >doc/clara-glo.1

doc: faq tut adv dev glossary

#
# Other.
#

test: clara
	./clara -p 2

install: all
	install -d $(BINDIR)
	install clara $(BINDIR)
	install selthresh $(BINDIR)
	install -d $(MANDIR)
	install doc/clara.1 doc/clara-dev.1 doc/clara-adv.1 $(MANDIR)
	install -d $(DOCDIR)
	install ANNOUNCE CHANGELOG doc/FAQ doc/*.html $(DOCDIR)

clean:
	rm -f clara sclara $(OBJS) doc/clara*.1 doc/clara*.html doc/FAQ
	rm -f $(SOURCES:%.c=.deps/%.d)
	rm -f acts patterns *session *.html *~ core
	rm -f www/*~
	rm -f doubts/*
	rm -f manager
	rm -f clara_marshalers.c clara_marshalers.h
stats:
	wc *.c *.h *.pl Makefile CHANGELOG | sort -n

TAGS: $(SOURCES) | hush
	@$(HUSH) "Building tags" etags $(SOURCES)

hush: hush.c
	@$(CC) -o $@ $<

%.o: %.c | hush clara_marshalers.h
	-@test -d .deps || mkdir -p .deps
	@$(HUSH) "Compiling $<" $(CC) -MMD -MF .deps/$*.d -c -o $@ $< $(CFLAGS)

clara_marshalers.h: clara_marshalers.list
	glib-genmarshal --header $< >$@
clara_marshalers.c: clara_marshalers.list
	glib-genmarshal --body $< >$@
