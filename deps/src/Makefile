CFLAGS  := -c -Wall -Werror -fpic -Wno-unknown-pragmas

UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
SHARED_LIBRARY = libhealpixwrapper.so
endif
ifeq ($(UNAME), Darwin)
SHARED_LIBRARY = libhealpixwrapper.dylib
endif

PKG_CONFIG_CFLAGS := $(shell pkg-config --cflags $(MY_PKG_CONFIG_PATH)/healpix_cxx.pc)
PKG_CONFIG_LIBS   := $(shell pkg-config --libs   $(MY_PKG_CONFIG_PATH)/healpix_cxx.pc)

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

