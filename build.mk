CC=gcc
AR=ar
RM=/bin/rm -f
INSTALL=cp -rpf
TDR=tdr

PREFIX?=/usr/local/tsf4g/

CFLAGS?=-Wall -Wconversion -Wcast-qual -Wpointer-arith -Wredundant-decls -Wmissing-declarations -Werror --pipe

ifdef MAKE_DEBUG
DEBUG_CFLAGS=-g -ggdb -DMAKE_DEBUG
else
DEBUG_CFLAGS=-O3 -DMAKE_RELEASE
endif

REALCC=$(CC) $(CFLAGS) $(DEBUG_CFLAGS) $(CINC)
REALLD=$(CC) $(LDPATH)
REALAR=$(AR)
REALINSTALL=$(INSTALL)
REALTDR=$(TDR) $(TDRINC)

SQL_FILE=$(SQL_TDR_FILE:.td=_tables.sql)
TYPES_HFILE=$(TYPES_TDR_FILE:.td=_types.h)
READER_HFILE=$(READER_TDR_FILE:.td=_reader.h)
READER_CFILE=$(READER_HFILE:.h=.c)
READER_OFILE=$(READER_HFILE:.h=.o)
WRITER_HFILE=$(WRITER_TDR_FILE:.td=_writer.h)
WRITER_CFILE=$(WRITER_HFILE:.h=.c)
WRITER_OFILE=$(WRITER_HFILE:.h=.o)


OFILE=$(CFILE:.c=.o) $(READER_CFILE:.c=.o) $(WRITER_CFILE:.c=.o)
DFILE=$(CFILE:.c=.d)
GENFILE=$(SQL_FILE) $(TYPES_HFILE) $(WRITER_HFILE) $(WRITER_CFILE) $(READER_HFILE) $(READER_CFILE)
.PHONY: all clean dep install tags

all:$(GENFILE) $(TARGET)

$(LIBRARY): $(OFILE)
	$(REALAR) r $(LIBRARY) $^

$(BINARY): $(OFILE)
	$(REALLD) -o $@ $^ $(DEPLIBS)

%.d: %.c $(GENFILE)
	$(REALCC) -MM -MF $@ $<
	sed -i 's,.*[:],$*.o: ,g' $@

%.o: %.c
	$(REALCC) -o $@ -c $<

$(SQL_FILE):$(SQL_TDR_FILE)
	$(REALTDR) -g sql $^

$(TYPES_HFILE):$(TYPES_TDR_FILE)
	$(REALTDR) -g types_h $^

$(READER_HFILE):$(READER_TDR_FILE)
	$(REALTDR) -g reader_h $^

$(READER_CFILE):$(READER_TDR_FILE)
	$(REALTDR) -g reader_c $^
	
$(WRITER_HFILE):$(WRITER_TDR_FILE)
	$(REALTDR) -g writer_h $^

$(WRITER_CFILE):$(WRITER_TDR_FILE)
	$(REALTDR) -g writer_c $^

-include $(DFILE)

debug:
	$(MAKE) all MAKE_DEBUG=1

tags:
	@find $(SOURCES) -name "*.c" -or -name "*.h" | xargs ctags -a --c-types=+p+x
	@find $(SOURCES) -name "*.h" -or -name "*.c" | cscope -Rbq

clean:
	$(RM) $(TARGET) $(OFILE) $(DFILE) $(GENFILE) tags cscope.in.out cscope.po.out cscope.out
