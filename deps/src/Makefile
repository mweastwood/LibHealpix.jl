CXX = g++
CXXFLAGS = -c -Wall -Werror -fpic -Wno-unknown-pragmas

HEALPIX = ../downloads/Healpix_3.20
INCLUDES = -I$(HEALPIX)/src/cxx/Healpix_cxx -I$(HEALPIX)/src/cxx/cxxsupport
LIBRARIES = -L$(HEALPIX)/lib -L$(HEALPIX)/src/cxx/gcc_with_fpic/lib -lhealpix_cxx -lcxxsupport -lsharp -lc_utils -lfftpack

all: libhealpixwrapper.so

transforms.o: transforms.cpp
	$(CXX) $(CXXFLAGS) transforms.cpp $(INCLUDES)

libhealpixwrapper.so: transforms.o
	$(CXX) -shared -o libhealpixwrapper.so transforms.o $(LIBRARIES)

clean:
	-rm *.o
	-rm *.so

install:
	cp libhealpixwrapper.so ..

