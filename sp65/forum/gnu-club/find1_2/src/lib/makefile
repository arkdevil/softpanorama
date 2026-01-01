# Makefile for GNU fast-find subprograms.
# Do not use this makefile directly, but only from `../Makefile'.

LIBPROGS = updatedb bigram code

.PHONY: all
all: $(LIBPROGS)

.PHONY: install
install: all
	-install -d $(LIBDIR)
	install $(LIBPROGS) $(LIBDIR)

updatedb: updatedb.sh
	sed -e "s,XLIBDIR,$(LIBDIR)," -e "s,XFCODES,$(FCODES)," \
	-e "s,XBINDIR,$(BINDIR)," updatedb.sh > updatedb

bigram: bigram.c
	$(CC) $(LDFLAGS) $(CFLAGS) -o $@ bigram.c

code: code.c
	$(CC) $(LDFLAGS) $(CFLAGS) -o $@ code.c

.PHONY: clean
clean:
	rm -f bigram code updatedb *.o core a.out tags TAGS
