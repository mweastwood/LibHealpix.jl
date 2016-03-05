CFLAGS  := -c -Wall -Werror -fpic -Wno-unknown-pragmas
HEALPIX := $(PWD)/../downloads/Healpix_3.30

UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
SHARED_LIBRARY = libhealpixwrapper.so
endif
ifeq ($(UNAME), Darwin)
SHARED_LIBRARY = libhealpixwrapper.dylib
endif

MY_PKG_CONFIG_PATH := $(PWD)/../usr/lib/pkgconfig:$(PKG_CONFIG_PATH)
PKG_CONFIG_CFLAGS := $(shell PKG_CONFIG_PATH=$(MY_PKG_CONFIG_PATH) pkg-config --cflags chealpix healpix_cxx)
PKG_CONFIG_LIBS   := $(shell PKG_CONFIG_PATH=$(MY_PKG_CONFIG_PATH) pkg-config --libs   chealpix healpix_cxx)

all: $(SHARED_LIBRARY)

map.o: map.cpp
	$(CXX) $(CFLAGS) $(PKG_CONFIG_CFLAGS) map.cpp

alm.o: alm.cpp
	$(CXX) $(CFLAGS) $(PKG_CONFIG_CFLAGS) alm.cpp

transforms.o: transforms.cpp
	$(CXX) $(CFLAGS) $(PKG_CONFIG_CFLAGS) transforms.cpp

$(SHARED_LIBRARY): map.o alm.o transforms.o
	$(CXX) $(PKG_CONFIG_LIBS) -shared -o $(SHARED_LIBRARY) map.o alm.o transforms.o

clean:
	-rm *.o
	-rm $(SHARED_LIBRARY)

install:
	@mkdir -p ../usr/lib
	@cp $(SHARED_LIBRARY) ../usr/lib

