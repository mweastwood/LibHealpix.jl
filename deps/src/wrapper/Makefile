CFLAGS := -c -Wall -Werror -fpic -Wno-unknown-pragmas -std=c++0x

UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
SHARED_LIBRARY = libhealpixwrapper.so
endif
ifeq ($(UNAME), Darwin)
SHARED_LIBRARY = libhealpixwrapper.dylib
endif

# NOTE: $(PWD) does not always give the location of the Makefile.  In particular, if you run `make
# -C ...` $(PWD) appears to give the directory from which you ran that command. Instead of the
#  directory specified as the argument to `-C`.
#
# http://stackoverflow.com/questions/18136918/how-to-get-current-relative-directory-of-your-makefile

ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
LIB_DIR  := $(ROOT_DIR)/../../usr/lib
MY_PKG_CONFIG_PATH := $(LIB_DIR)/pkgconfig:$(PKG_CONFIG_PATH)
PKG_CONFIG_CFLAGS  := $(shell PKG_CONFIG_PATH=$(MY_PKG_CONFIG_PATH) pkg-config --cflags chealpix healpix_cxx)
PKG_CONFIG_LIBS    := $(shell PKG_CONFIG_PATH=$(MY_PKG_CONFIG_PATH) pkg-config --libs   chealpix healpix_cxx)

all: $(SHARED_LIBRARY)

wrapper.o: wrapper.cpp
	$(CXX) $(CFLAGS) $(PKG_CONFIG_CFLAGS) wrapper.cpp

$(SHARED_LIBRARY): wrapper.o
	$(CXX) -Wl,--no-as-needed $(PKG_CONFIG_LIBS) -Wl,-rpath,$(LIB_DIR) -shared -o $(SHARED_LIBRARY) wrapper.o

clean:
	-rm -f wrapper.o
	-rm -f $(SHARED_LIBRARY)

install:
	mkdir -p $(LIB_DIR)
	install $(SHARED_LIBRARY) $(LIB_DIR)

