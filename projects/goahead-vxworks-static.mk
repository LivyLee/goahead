#
#   goahead-vxworks-static.mk -- Makefile to build Embedthis GoAhead for vxworks
#

NAME                  := goahead
VERSION               := 3.4.0
PROFILE               ?= static
ARCH                  ?= $(shell echo $(WIND_HOST_TYPE) | sed 's/-.*//')
CPU                   ?= $(subst X86,PENTIUM,$(shell echo $(ARCH) | tr a-z A-Z))
OS                    ?= vxworks
CC                    ?= cc$(subst x86,pentium,$(ARCH))
LD                    ?= ld
CONFIG                ?= $(OS)-$(ARCH)-$(PROFILE)
BUILD                 ?= build/$(CONFIG)
LBIN                  ?= $(BUILD)/bin
PATH                  := $(LBIN):$(PATH)

ME_COM_EST            ?= 1
ME_COM_OPENSSL        ?= 0
ME_COM_OSDEP          ?= 1
ME_COM_SSL            ?= 1
ME_COM_WINSDK         ?= 1

ifeq ($(ME_COM_EST),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_OPENSSL),1)
    ME_COM_SSL := 1
endif

ME_COM_COMPILER_PATH  ?= cc$(subst x86,pentium,$(ARCH))
ME_COM_LIB_PATH       ?= ar
ME_COM_LINK_PATH      ?= ld
ME_COM_OPENSSL_PATH   ?= /usr/src/openssl
ME_COM_VXWORKS_PATH   ?= $(WIND_BASE)

export WIND_HOME      ?= $(WIND_BASE)/..
export PATH           := $(WIND_GNU_PATH)/$(WIND_HOST_TYPE)/bin:$(PATH)

CFLAGS                += -fno-builtin -fno-defer-pop -fvolatile -w
DFLAGS                += -DVXWORKS -DRW_MULTI_THREAD -D_GNU_TOOL -DCPU=PENTIUM $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_EST=$(ME_COM_EST) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_OSDEP=$(ME_COM_OSDEP) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_WINSDK=$(ME_COM_WINSDK) 
IFLAGS                += "-Ibuild/$(CONFIG)/inc -I$(WIND_BASE)/target/h -I$(WIND_BASE)/target/h/wrn/coreip"
LDFLAGS               += '-Wl,-r'
LIBPATHS              += -Lbuild/$(CONFIG)/bin
LIBS                  += -lgcc

DEBUG                 ?= debug
CFLAGS-debug          ?= -g
DFLAGS-debug          ?= -DME_DEBUG
LDFLAGS-debug         ?= -g
DFLAGS-release        ?= 
CFLAGS-release        ?= -O2
LDFLAGS-release       ?= 
CFLAGS                += $(CFLAGS-$(DEBUG))
DFLAGS                += $(DFLAGS-$(DEBUG))
LDFLAGS               += $(LDFLAGS-$(DEBUG))

ME_ROOT_PREFIX        ?= deploy
ME_BASE_PREFIX        ?= $(ME_ROOT_PREFIX)
ME_DATA_PREFIX        ?= $(ME_VAPP_PREFIX)
ME_STATE_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_BIN_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_INC_PREFIX         ?= $(ME_VAPP_PREFIX)/inc
ME_LIB_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_MAN_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_SBIN_PREFIX        ?= $(ME_VAPP_PREFIX)
ME_ETC_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_WEB_PREFIX         ?= $(ME_VAPP_PREFIX)/web
ME_LOG_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_SPOOL_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_CACHE_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_APP_PREFIX         ?= $(ME_BASE_PREFIX)
ME_VAPP_PREFIX        ?= $(ME_APP_PREFIX)
ME_SRC_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/src/$(NAME)-$(VERSION)


TARGETS               += build/$(CONFIG)/bin/ca.crt
TARGETS               += test/cgi-bin/cgitest.out
TARGETS               += build/$(CONFIG)/bin/goahead.out
TARGETS               += build/$(CONFIG)/bin/goahead-test.out
TARGETS               += build/$(CONFIG)/bin/gopass.out

unexport CDPATH

ifndef SHOW
.SILENT:
endif

all build compile: prep $(TARGETS)

.PHONY: prep

prep:
	@echo "      [Info] Use "make SHOW=1" to trace executed commands."
	@if [ "$(CONFIG)" = "" ] ; then echo WARNING: CONFIG not set ; exit 255 ; fi
	@if [ "$(ME_APP_PREFIX)" = "" ] ; then echo WARNING: ME_APP_PREFIX not set ; exit 255 ; fi
	@if [ "$(WIND_BASE)" = "" ] ; then echo WARNING: WIND_BASE not set. Run wrenv.sh. ; exit 255 ; fi
	@if [ "$(WIND_HOST_TYPE)" = "" ] ; then echo WARNING: WIND_HOST_TYPE not set. Run wrenv.sh. ; exit 255 ; fi
	@if [ "$(WIND_GNU_PATH)" = "" ] ; then echo WARNING: WIND_GNU_PATH not set. Run wrenv.sh. ; exit 255 ; fi
	@[ ! -x $(BUILD)/bin ] && mkdir -p $(BUILD)/bin; true
	@[ ! -x $(BUILD)/inc ] && mkdir -p $(BUILD)/inc; true
	@[ ! -x $(BUILD)/obj ] && mkdir -p $(BUILD)/obj; true
	@[ ! -f $(BUILD)/inc/me.h ] && cp projects/goahead-vxworks-static-me.h $(BUILD)/inc/me.h ; true
	@if ! diff $(BUILD)/inc/me.h projects/goahead-vxworks-static-me.h >/dev/null ; then\
		cp projects/goahead-vxworks-static-me.h $(BUILD)/inc/me.h  ; \
	fi; true
	@if [ -f "$(BUILD)/.makeflags" ] ; then \
		if [ "$(MAKEFLAGS)" != "`cat $(BUILD)/.makeflags`" ] ; then \
			echo "   [Warning] Make flags have changed since the last build: "`cat $(BUILD)/.makeflags`"" ; \
		fi ; \
	fi
	@echo $(MAKEFLAGS) >$(BUILD)/.makeflags

clean:
	rm -f "build/$(CONFIG)/obj/action.o"
	rm -f "build/$(CONFIG)/obj/alloc.o"
	rm -f "build/$(CONFIG)/obj/auth.o"
	rm -f "build/$(CONFIG)/obj/cgi.o"
	rm -f "build/$(CONFIG)/obj/cgitest.o"
	rm -f "build/$(CONFIG)/obj/crypt.o"
	rm -f "build/$(CONFIG)/obj/est.o"
	rm -f "build/$(CONFIG)/obj/estLib.o"
	rm -f "build/$(CONFIG)/obj/file.o"
	rm -f "build/$(CONFIG)/obj/fs.o"
	rm -f "build/$(CONFIG)/obj/goahead.o"
	rm -f "build/$(CONFIG)/obj/gopass.o"
	rm -f "build/$(CONFIG)/obj/http.o"
	rm -f "build/$(CONFIG)/obj/js.o"
	rm -f "build/$(CONFIG)/obj/jst.o"
	rm -f "build/$(CONFIG)/obj/matrixssl.o"
	rm -f "build/$(CONFIG)/obj/nanossl.o"
	rm -f "build/$(CONFIG)/obj/openssl.o"
	rm -f "build/$(CONFIG)/obj/options.o"
	rm -f "build/$(CONFIG)/obj/osdep.o"
	rm -f "build/$(CONFIG)/obj/rom-documents.o"
	rm -f "build/$(CONFIG)/obj/route.o"
	rm -f "build/$(CONFIG)/obj/runtime.o"
	rm -f "build/$(CONFIG)/obj/socket.o"
	rm -f "build/$(CONFIG)/obj/test.o"
	rm -f "build/$(CONFIG)/obj/upload.o"
	rm -f "build/$(CONFIG)/bin/ca.crt"
	rm -f "test/cgi-bin/cgitest.out"
	rm -f "build/$(CONFIG)/bin/goahead.out"
	rm -f "build/$(CONFIG)/bin/goahead-test.out"
	rm -f "build/$(CONFIG)/bin/gopass.out"
	rm -f "build/$(CONFIG)/bin/libest.a"
	rm -f "build/$(CONFIG)/bin/libgo.a"

clobber: clean
	rm -fr ./$(BUILD)


#
#   ca-crt
#
DEPS_1 += src/paks/est/ca.crt

build/$(CONFIG)/bin/ca.crt: $(DEPS_1)
	@echo '      [Copy] build/$(CONFIG)/bin/ca.crt'
	mkdir -p "build/$(CONFIG)/bin"
	cp src/paks/est/ca.crt build/$(CONFIG)/bin/ca.crt

#
#   goahead.h
#
DEPS_2 += src/goahead.h

build/$(CONFIG)/inc/goahead.h: $(DEPS_2)
	@echo '      [Copy] build/$(CONFIG)/inc/goahead.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/goahead.h build/$(CONFIG)/inc/goahead.h

#
#   js.h
#
DEPS_3 += src/js.h

build/$(CONFIG)/inc/js.h: $(DEPS_3)
	@echo '      [Copy] build/$(CONFIG)/inc/js.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/js.h build/$(CONFIG)/inc/js.h

#
#   me.h
#
build/$(CONFIG)/inc/me.h: $(DEPS_4)
	@echo '      [Copy] build/$(CONFIG)/inc/me.h'

#
#   cgitest.o
#
DEPS_5 += build/$(CONFIG)/inc/me.h

build/$(CONFIG)/obj/cgitest.o: \
    test/cgitest.c $(DEPS_5)
	@echo '   [Compile] build/$(CONFIG)/obj/cgitest.o'
	$(CC) -c -o build/$(CONFIG)/obj/cgitest.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" test/cgitest.c

#
#   cgitest
#
DEPS_6 += build/$(CONFIG)/inc/goahead.h
DEPS_6 += build/$(CONFIG)/inc/js.h
DEPS_6 += build/$(CONFIG)/inc/me.h
DEPS_6 += build/$(CONFIG)/obj/cgitest.o

test/cgi-bin/cgitest.out: $(DEPS_6)
	@echo '      [Link] test/cgi-bin/cgitest.out'
	$(CC) -o test/cgi-bin/cgitest.out $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/cgitest.o" $(LIBS) -Wl,-r 


#
#   est.h
#
DEPS_7 += src/paks/est/est.h

build/$(CONFIG)/inc/est.h: $(DEPS_7)
	@echo '      [Copy] build/$(CONFIG)/inc/est.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/est/est.h build/$(CONFIG)/inc/est.h

#
#   osdep.h
#
DEPS_8 += src/paks/osdep/osdep.h
DEPS_8 += build/$(CONFIG)/inc/me.h

build/$(CONFIG)/inc/osdep.h: $(DEPS_8)
	@echo '      [Copy] build/$(CONFIG)/inc/osdep.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/osdep/osdep.h build/$(CONFIG)/inc/osdep.h

#
#   estLib.o
#
DEPS_9 += build/$(CONFIG)/inc/me.h
DEPS_9 += build/$(CONFIG)/inc/est.h
DEPS_9 += build/$(CONFIG)/inc/osdep.h

build/$(CONFIG)/obj/estLib.o: \
    src/paks/est/estLib.c $(DEPS_9)
	@echo '   [Compile] build/$(CONFIG)/obj/estLib.o'
	$(CC) -c -o build/$(CONFIG)/obj/estLib.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/est/estLib.c

ifeq ($(ME_COM_EST),1)
#
#   libest
#
DEPS_10 += build/$(CONFIG)/inc/est.h
DEPS_10 += build/$(CONFIG)/inc/me.h
DEPS_10 += build/$(CONFIG)/inc/osdep.h
DEPS_10 += build/$(CONFIG)/obj/estLib.o

build/$(CONFIG)/bin/libest.a: $(DEPS_10)
	@echo '      [Link] build/$(CONFIG)/bin/libest.a'
	ar -cr build/$(CONFIG)/bin/libest.a "build/$(CONFIG)/obj/estLib.o"
endif

#
#   action.o
#
DEPS_11 += build/$(CONFIG)/inc/me.h
DEPS_11 += build/$(CONFIG)/inc/goahead.h
DEPS_11 += build/$(CONFIG)/inc/osdep.h

build/$(CONFIG)/obj/action.o: \
    src/action.c $(DEPS_11)
	@echo '   [Compile] build/$(CONFIG)/obj/action.o'
	$(CC) -c -o build/$(CONFIG)/obj/action.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/action.c

#
#   alloc.o
#
DEPS_12 += build/$(CONFIG)/inc/me.h
DEPS_12 += build/$(CONFIG)/inc/goahead.h

build/$(CONFIG)/obj/alloc.o: \
    src/alloc.c $(DEPS_12)
	@echo '   [Compile] build/$(CONFIG)/obj/alloc.o'
	$(CC) -c -o build/$(CONFIG)/obj/alloc.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/alloc.c

#
#   auth.o
#
DEPS_13 += build/$(CONFIG)/inc/me.h
DEPS_13 += build/$(CONFIG)/inc/goahead.h

build/$(CONFIG)/obj/auth.o: \
    src/auth.c $(DEPS_13)
	@echo '   [Compile] build/$(CONFIG)/obj/auth.o'
	$(CC) -c -o build/$(CONFIG)/obj/auth.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/auth.c

#
#   cgi.o
#
DEPS_14 += build/$(CONFIG)/inc/me.h
DEPS_14 += build/$(CONFIG)/inc/goahead.h

build/$(CONFIG)/obj/cgi.o: \
    src/cgi.c $(DEPS_14)
	@echo '   [Compile] build/$(CONFIG)/obj/cgi.o'
	$(CC) -c -o build/$(CONFIG)/obj/cgi.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/cgi.c

#
#   crypt.o
#
DEPS_15 += build/$(CONFIG)/inc/me.h
DEPS_15 += build/$(CONFIG)/inc/goahead.h

build/$(CONFIG)/obj/crypt.o: \
    src/crypt.c $(DEPS_15)
	@echo '   [Compile] build/$(CONFIG)/obj/crypt.o'
	$(CC) -c -o build/$(CONFIG)/obj/crypt.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/crypt.c

#
#   file.o
#
DEPS_16 += build/$(CONFIG)/inc/me.h
DEPS_16 += build/$(CONFIG)/inc/goahead.h

build/$(CONFIG)/obj/file.o: \
    src/file.c $(DEPS_16)
	@echo '   [Compile] build/$(CONFIG)/obj/file.o'
	$(CC) -c -o build/$(CONFIG)/obj/file.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/file.c

#
#   fs.o
#
DEPS_17 += build/$(CONFIG)/inc/me.h
DEPS_17 += build/$(CONFIG)/inc/goahead.h

build/$(CONFIG)/obj/fs.o: \
    src/fs.c $(DEPS_17)
	@echo '   [Compile] build/$(CONFIG)/obj/fs.o'
	$(CC) -c -o build/$(CONFIG)/obj/fs.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/fs.c

#
#   http.o
#
DEPS_18 += build/$(CONFIG)/inc/me.h
DEPS_18 += build/$(CONFIG)/inc/goahead.h

build/$(CONFIG)/obj/http.o: \
    src/http.c $(DEPS_18)
	@echo '   [Compile] build/$(CONFIG)/obj/http.o'
	$(CC) -c -o build/$(CONFIG)/obj/http.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/http.c

#
#   js.o
#
DEPS_19 += build/$(CONFIG)/inc/me.h
DEPS_19 += build/$(CONFIG)/inc/js.h
DEPS_19 += build/$(CONFIG)/inc/goahead.h

build/$(CONFIG)/obj/js.o: \
    src/js.c $(DEPS_19)
	@echo '   [Compile] build/$(CONFIG)/obj/js.o'
	$(CC) -c -o build/$(CONFIG)/obj/js.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/js.c

#
#   jst.o
#
DEPS_20 += build/$(CONFIG)/inc/me.h
DEPS_20 += build/$(CONFIG)/inc/goahead.h
DEPS_20 += build/$(CONFIG)/inc/js.h

build/$(CONFIG)/obj/jst.o: \
    src/jst.c $(DEPS_20)
	@echo '   [Compile] build/$(CONFIG)/obj/jst.o'
	$(CC) -c -o build/$(CONFIG)/obj/jst.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/jst.c

#
#   options.o
#
DEPS_21 += build/$(CONFIG)/inc/me.h
DEPS_21 += build/$(CONFIG)/inc/goahead.h

build/$(CONFIG)/obj/options.o: \
    src/options.c $(DEPS_21)
	@echo '   [Compile] build/$(CONFIG)/obj/options.o'
	$(CC) -c -o build/$(CONFIG)/obj/options.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/options.c

#
#   osdep.o
#
DEPS_22 += build/$(CONFIG)/inc/me.h
DEPS_22 += build/$(CONFIG)/inc/goahead.h

build/$(CONFIG)/obj/osdep.o: \
    src/osdep.c $(DEPS_22)
	@echo '   [Compile] build/$(CONFIG)/obj/osdep.o'
	$(CC) -c -o build/$(CONFIG)/obj/osdep.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/osdep.c

#
#   rom-documents.o
#
DEPS_23 += build/$(CONFIG)/inc/me.h
DEPS_23 += build/$(CONFIG)/inc/goahead.h

build/$(CONFIG)/obj/rom-documents.o: \
    src/rom-documents.c $(DEPS_23)
	@echo '   [Compile] build/$(CONFIG)/obj/rom-documents.o'
	$(CC) -c -o build/$(CONFIG)/obj/rom-documents.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/rom-documents.c

#
#   route.o
#
DEPS_24 += build/$(CONFIG)/inc/me.h
DEPS_24 += build/$(CONFIG)/inc/goahead.h

build/$(CONFIG)/obj/route.o: \
    src/route.c $(DEPS_24)
	@echo '   [Compile] build/$(CONFIG)/obj/route.o'
	$(CC) -c -o build/$(CONFIG)/obj/route.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/route.c

#
#   runtime.o
#
DEPS_25 += build/$(CONFIG)/inc/me.h
DEPS_25 += build/$(CONFIG)/inc/goahead.h

build/$(CONFIG)/obj/runtime.o: \
    src/runtime.c $(DEPS_25)
	@echo '   [Compile] build/$(CONFIG)/obj/runtime.o'
	$(CC) -c -o build/$(CONFIG)/obj/runtime.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/runtime.c

#
#   socket.o
#
DEPS_26 += build/$(CONFIG)/inc/me.h
DEPS_26 += build/$(CONFIG)/inc/goahead.h

build/$(CONFIG)/obj/socket.o: \
    src/socket.c $(DEPS_26)
	@echo '   [Compile] build/$(CONFIG)/obj/socket.o'
	$(CC) -c -o build/$(CONFIG)/obj/socket.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/socket.c

#
#   est.o
#
DEPS_27 += build/$(CONFIG)/inc/me.h
DEPS_27 += build/$(CONFIG)/inc/goahead.h
DEPS_27 += build/$(CONFIG)/inc/est.h

build/$(CONFIG)/obj/est.o: \
    src/ssl/est.c $(DEPS_27)
	@echo '   [Compile] build/$(CONFIG)/obj/est.o'
	$(CC) -c -o build/$(CONFIG)/obj/est.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/ssl/est.c

#
#   matrixssl.o
#
DEPS_28 += build/$(CONFIG)/inc/me.h
DEPS_28 += build/$(CONFIG)/inc/goahead.h

build/$(CONFIG)/obj/matrixssl.o: \
    src/ssl/matrixssl.c $(DEPS_28)
	@echo '   [Compile] build/$(CONFIG)/obj/matrixssl.o'
	$(CC) -c -o build/$(CONFIG)/obj/matrixssl.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/ssl/matrixssl.c

#
#   nanossl.o
#
DEPS_29 += build/$(CONFIG)/inc/me.h

build/$(CONFIG)/obj/nanossl.o: \
    src/ssl/nanossl.c $(DEPS_29)
	@echo '   [Compile] build/$(CONFIG)/obj/nanossl.o'
	$(CC) -c -o build/$(CONFIG)/obj/nanossl.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/ssl/nanossl.c

#
#   openssl.o
#
DEPS_30 += build/$(CONFIG)/inc/me.h
DEPS_30 += build/$(CONFIG)/inc/osdep.h
DEPS_30 += build/$(CONFIG)/inc/goahead.h

build/$(CONFIG)/obj/openssl.o: \
    src/ssl/openssl.c $(DEPS_30)
	@echo '   [Compile] build/$(CONFIG)/obj/openssl.o'
	$(CC) -c -o build/$(CONFIG)/obj/openssl.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/ssl/openssl.c

#
#   upload.o
#
DEPS_31 += build/$(CONFIG)/inc/me.h
DEPS_31 += build/$(CONFIG)/inc/goahead.h

build/$(CONFIG)/obj/upload.o: \
    src/upload.c $(DEPS_31)
	@echo '   [Compile] build/$(CONFIG)/obj/upload.o'
	$(CC) -c -o build/$(CONFIG)/obj/upload.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/upload.c

#
#   libgo
#
DEPS_32 += build/$(CONFIG)/inc/est.h
DEPS_32 += build/$(CONFIG)/inc/me.h
DEPS_32 += build/$(CONFIG)/inc/osdep.h
DEPS_32 += build/$(CONFIG)/obj/estLib.o
ifeq ($(ME_COM_EST),1)
    DEPS_32 += build/$(CONFIG)/bin/libest.a
endif
DEPS_32 += build/$(CONFIG)/inc/goahead.h
DEPS_32 += build/$(CONFIG)/inc/js.h
DEPS_32 += build/$(CONFIG)/obj/action.o
DEPS_32 += build/$(CONFIG)/obj/alloc.o
DEPS_32 += build/$(CONFIG)/obj/auth.o
DEPS_32 += build/$(CONFIG)/obj/cgi.o
DEPS_32 += build/$(CONFIG)/obj/crypt.o
DEPS_32 += build/$(CONFIG)/obj/file.o
DEPS_32 += build/$(CONFIG)/obj/fs.o
DEPS_32 += build/$(CONFIG)/obj/http.o
DEPS_32 += build/$(CONFIG)/obj/js.o
DEPS_32 += build/$(CONFIG)/obj/jst.o
DEPS_32 += build/$(CONFIG)/obj/options.o
DEPS_32 += build/$(CONFIG)/obj/osdep.o
DEPS_32 += build/$(CONFIG)/obj/rom-documents.o
DEPS_32 += build/$(CONFIG)/obj/route.o
DEPS_32 += build/$(CONFIG)/obj/runtime.o
DEPS_32 += build/$(CONFIG)/obj/socket.o
DEPS_32 += build/$(CONFIG)/obj/est.o
DEPS_32 += build/$(CONFIG)/obj/matrixssl.o
DEPS_32 += build/$(CONFIG)/obj/nanossl.o
DEPS_32 += build/$(CONFIG)/obj/openssl.o
DEPS_32 += build/$(CONFIG)/obj/upload.o

build/$(CONFIG)/bin/libgo.a: $(DEPS_32)
	@echo '      [Link] build/$(CONFIG)/bin/libgo.a'
	ar -cr build/$(CONFIG)/bin/libgo.a "build/$(CONFIG)/obj/action.o" "build/$(CONFIG)/obj/alloc.o" "build/$(CONFIG)/obj/auth.o" "build/$(CONFIG)/obj/cgi.o" "build/$(CONFIG)/obj/crypt.o" "build/$(CONFIG)/obj/file.o" "build/$(CONFIG)/obj/fs.o" "build/$(CONFIG)/obj/http.o" "build/$(CONFIG)/obj/js.o" "build/$(CONFIG)/obj/jst.o" "build/$(CONFIG)/obj/options.o" "build/$(CONFIG)/obj/osdep.o" "build/$(CONFIG)/obj/rom-documents.o" "build/$(CONFIG)/obj/route.o" "build/$(CONFIG)/obj/runtime.o" "build/$(CONFIG)/obj/socket.o" "build/$(CONFIG)/obj/est.o" "build/$(CONFIG)/obj/matrixssl.o" "build/$(CONFIG)/obj/nanossl.o" "build/$(CONFIG)/obj/openssl.o" "build/$(CONFIG)/obj/upload.o"

#
#   goahead.o
#
DEPS_33 += build/$(CONFIG)/inc/me.h
DEPS_33 += build/$(CONFIG)/inc/goahead.h
DEPS_33 += build/$(CONFIG)/inc/osdep.h

build/$(CONFIG)/obj/goahead.o: \
    src/goahead.c $(DEPS_33)
	@echo '   [Compile] build/$(CONFIG)/obj/goahead.o'
	$(CC) -c -o build/$(CONFIG)/obj/goahead.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/goahead.c

#
#   goahead
#
DEPS_34 += build/$(CONFIG)/inc/est.h
DEPS_34 += build/$(CONFIG)/inc/me.h
DEPS_34 += build/$(CONFIG)/inc/osdep.h
DEPS_34 += build/$(CONFIG)/obj/estLib.o
ifeq ($(ME_COM_EST),1)
    DEPS_34 += build/$(CONFIG)/bin/libest.a
endif
DEPS_34 += build/$(CONFIG)/inc/goahead.h
DEPS_34 += build/$(CONFIG)/inc/js.h
DEPS_34 += build/$(CONFIG)/obj/action.o
DEPS_34 += build/$(CONFIG)/obj/alloc.o
DEPS_34 += build/$(CONFIG)/obj/auth.o
DEPS_34 += build/$(CONFIG)/obj/cgi.o
DEPS_34 += build/$(CONFIG)/obj/crypt.o
DEPS_34 += build/$(CONFIG)/obj/file.o
DEPS_34 += build/$(CONFIG)/obj/fs.o
DEPS_34 += build/$(CONFIG)/obj/http.o
DEPS_34 += build/$(CONFIG)/obj/js.o
DEPS_34 += build/$(CONFIG)/obj/jst.o
DEPS_34 += build/$(CONFIG)/obj/options.o
DEPS_34 += build/$(CONFIG)/obj/osdep.o
DEPS_34 += build/$(CONFIG)/obj/rom-documents.o
DEPS_34 += build/$(CONFIG)/obj/route.o
DEPS_34 += build/$(CONFIG)/obj/runtime.o
DEPS_34 += build/$(CONFIG)/obj/socket.o
DEPS_34 += build/$(CONFIG)/obj/est.o
DEPS_34 += build/$(CONFIG)/obj/matrixssl.o
DEPS_34 += build/$(CONFIG)/obj/nanossl.o
DEPS_34 += build/$(CONFIG)/obj/openssl.o
DEPS_34 += build/$(CONFIG)/obj/upload.o
DEPS_34 += build/$(CONFIG)/bin/libgo.a
DEPS_34 += build/$(CONFIG)/obj/goahead.o

LIBS_34 += -lgo
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_34 += -lssl
    LIBPATHS_34 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_34 += -lcrypto
    LIBPATHS_34 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_EST),1)
    LIBS_34 += -lest
endif

build/$(CONFIG)/bin/goahead.out: $(DEPS_34)
	@echo '      [Link] build/$(CONFIG)/bin/goahead.out'
	$(CC) -o build/$(CONFIG)/bin/goahead.out $(LDFLAGS) $(LIBPATHS)  "build/$(CONFIG)/obj/goahead.o" $(LIBPATHS_34) $(LIBS_34) $(LIBS_34) $(LIBS) -Wl,-r 

#
#   test.o
#
DEPS_35 += build/$(CONFIG)/inc/me.h
DEPS_35 += build/$(CONFIG)/inc/goahead.h
DEPS_35 += build/$(CONFIG)/inc/js.h
DEPS_35 += build/$(CONFIG)/inc/osdep.h

build/$(CONFIG)/obj/test.o: \
    test/test.c $(DEPS_35)
	@echo '   [Compile] build/$(CONFIG)/obj/test.o'
	$(CC) -c -o build/$(CONFIG)/obj/test.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" test/test.c

#
#   goahead-test
#
DEPS_36 += build/$(CONFIG)/inc/est.h
DEPS_36 += build/$(CONFIG)/inc/me.h
DEPS_36 += build/$(CONFIG)/inc/osdep.h
DEPS_36 += build/$(CONFIG)/obj/estLib.o
ifeq ($(ME_COM_EST),1)
    DEPS_36 += build/$(CONFIG)/bin/libest.a
endif
DEPS_36 += build/$(CONFIG)/inc/goahead.h
DEPS_36 += build/$(CONFIG)/inc/js.h
DEPS_36 += build/$(CONFIG)/obj/action.o
DEPS_36 += build/$(CONFIG)/obj/alloc.o
DEPS_36 += build/$(CONFIG)/obj/auth.o
DEPS_36 += build/$(CONFIG)/obj/cgi.o
DEPS_36 += build/$(CONFIG)/obj/crypt.o
DEPS_36 += build/$(CONFIG)/obj/file.o
DEPS_36 += build/$(CONFIG)/obj/fs.o
DEPS_36 += build/$(CONFIG)/obj/http.o
DEPS_36 += build/$(CONFIG)/obj/js.o
DEPS_36 += build/$(CONFIG)/obj/jst.o
DEPS_36 += build/$(CONFIG)/obj/options.o
DEPS_36 += build/$(CONFIG)/obj/osdep.o
DEPS_36 += build/$(CONFIG)/obj/rom-documents.o
DEPS_36 += build/$(CONFIG)/obj/route.o
DEPS_36 += build/$(CONFIG)/obj/runtime.o
DEPS_36 += build/$(CONFIG)/obj/socket.o
DEPS_36 += build/$(CONFIG)/obj/est.o
DEPS_36 += build/$(CONFIG)/obj/matrixssl.o
DEPS_36 += build/$(CONFIG)/obj/nanossl.o
DEPS_36 += build/$(CONFIG)/obj/openssl.o
DEPS_36 += build/$(CONFIG)/obj/upload.o
DEPS_36 += build/$(CONFIG)/bin/libgo.a
DEPS_36 += build/$(CONFIG)/obj/test.o

LIBS_36 += -lgo
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_36 += -lssl
    LIBPATHS_36 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_36 += -lcrypto
    LIBPATHS_36 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_EST),1)
    LIBS_36 += -lest
endif

build/$(CONFIG)/bin/goahead-test.out: $(DEPS_36)
	@echo '      [Link] build/$(CONFIG)/bin/goahead-test.out'
	$(CC) -o build/$(CONFIG)/bin/goahead-test.out $(LDFLAGS) $(LIBPATHS)  "build/$(CONFIG)/obj/test.o" $(LIBPATHS_36) $(LIBS_36) $(LIBS_36) $(LIBS) -Wl,-r 

#
#   gopass.o
#
DEPS_37 += build/$(CONFIG)/inc/me.h
DEPS_37 += build/$(CONFIG)/inc/goahead.h
DEPS_37 += build/$(CONFIG)/inc/osdep.h

build/$(CONFIG)/obj/gopass.o: \
    src/utils/gopass.c $(DEPS_37)
	@echo '   [Compile] build/$(CONFIG)/obj/gopass.o'
	$(CC) -c -o build/$(CONFIG)/obj/gopass.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/utils/gopass.c

#
#   gopass
#
DEPS_38 += build/$(CONFIG)/inc/est.h
DEPS_38 += build/$(CONFIG)/inc/me.h
DEPS_38 += build/$(CONFIG)/inc/osdep.h
DEPS_38 += build/$(CONFIG)/obj/estLib.o
ifeq ($(ME_COM_EST),1)
    DEPS_38 += build/$(CONFIG)/bin/libest.a
endif
DEPS_38 += build/$(CONFIG)/inc/goahead.h
DEPS_38 += build/$(CONFIG)/inc/js.h
DEPS_38 += build/$(CONFIG)/obj/action.o
DEPS_38 += build/$(CONFIG)/obj/alloc.o
DEPS_38 += build/$(CONFIG)/obj/auth.o
DEPS_38 += build/$(CONFIG)/obj/cgi.o
DEPS_38 += build/$(CONFIG)/obj/crypt.o
DEPS_38 += build/$(CONFIG)/obj/file.o
DEPS_38 += build/$(CONFIG)/obj/fs.o
DEPS_38 += build/$(CONFIG)/obj/http.o
DEPS_38 += build/$(CONFIG)/obj/js.o
DEPS_38 += build/$(CONFIG)/obj/jst.o
DEPS_38 += build/$(CONFIG)/obj/options.o
DEPS_38 += build/$(CONFIG)/obj/osdep.o
DEPS_38 += build/$(CONFIG)/obj/rom-documents.o
DEPS_38 += build/$(CONFIG)/obj/route.o
DEPS_38 += build/$(CONFIG)/obj/runtime.o
DEPS_38 += build/$(CONFIG)/obj/socket.o
DEPS_38 += build/$(CONFIG)/obj/est.o
DEPS_38 += build/$(CONFIG)/obj/matrixssl.o
DEPS_38 += build/$(CONFIG)/obj/nanossl.o
DEPS_38 += build/$(CONFIG)/obj/openssl.o
DEPS_38 += build/$(CONFIG)/obj/upload.o
DEPS_38 += build/$(CONFIG)/bin/libgo.a
DEPS_38 += build/$(CONFIG)/obj/gopass.o

LIBS_38 += -lgo
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_38 += -lssl
    LIBPATHS_38 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_38 += -lcrypto
    LIBPATHS_38 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_EST),1)
    LIBS_38 += -lest
endif

build/$(CONFIG)/bin/gopass.out: $(DEPS_38)
	@echo '      [Link] build/$(CONFIG)/bin/gopass.out'
	$(CC) -o build/$(CONFIG)/bin/gopass.out $(LDFLAGS) $(LIBPATHS)  "build/$(CONFIG)/obj/gopass.o" $(LIBPATHS_38) $(LIBS_38) $(LIBS_38) $(LIBS) -Wl,-r 

#
#   stop
#
stop: $(DEPS_39)

#
#   installBinary
#
installBinary: $(DEPS_40)

#
#   start
#
start: $(DEPS_41)

#
#   install
#
DEPS_42 += stop
DEPS_42 += installBinary
DEPS_42 += start

install: $(DEPS_42)

#
#   uninstall
#
DEPS_43 += stop

uninstall: $(DEPS_43)

#
#   version
#
version: $(DEPS_44)
	echo 3.4.0

