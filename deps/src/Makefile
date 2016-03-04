CXXFLAGS = -c -Wall -Werror -fpic -Wno-unknown-pragmas

HEALPIX = ../downloads/Healpix_3.30
INCLUDES = -I$(HEALPIX)/src/cxx/Healpix_cxx -I$(HEALPIX)/src/cxx/cxxsupport
LIBRARIES = -L$(HEALPIX)/lib -L$(HEALPIX)/src/cxx/gcc_with_fpic/lib -lhealpix_cxx -lcxxsupport -lsharp -lc_utils -lfftpack

UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
SHARED_LIBRARY = libhealpixwrapper.so
endif
ifeq ($(UNAME), Darwin)
SHARED_LIBRARY = libhealpixwrapper.dylib
endif

all: $(SHARED_LIBRARY)

map.o: map.cpp
	$(CXX) $(CXXFLAGS) map.cpp $(INCLUDES)

alm.o: alm.cpp
	$(CXX) $(CXXFLAGS) alm.cpp $(INCLUDES)

transforms.o: transforms.cpp
	$(CXX) $(CXXFLAGS) transforms.cpp $(INCLUDES)

$(SHARED_LIBRARY): map.o alm.o transforms.o
	$(CXX) -shared -o $(SHARED_LIBRARY) map.o alm.o transforms.o $(LIBRARIES)

clean:
	-rm *.o
	-rm $(SHARED_LIBRARY)

install:
	@mkdir -p ../usr/lib
	@cp $(SHARED_LIBRARY) ../usr/lib

