CXX = g++
CXXFLAGS = -c -Wall -Werror -fpic -Wno-unknown-pragmas

HEALPIX = ../downloads/Healpix_3.20/src/cxx
INCLUDES = -I$(HEALPIX)/Healpix_cxx -I$(HEALPIX)/cxxsupport

all: libhealpixwrapper.so

transforms.o: transforms.cpp
	$(CXX) $(CXXFLAGS) transforms.cpp $(INCLUDES)

libhealpixwrapper.so: transforms.o
	$(CXX) -shared -o libhealpixwrapper.so transforms.o -lhealpix_cxx -lcxxsupport -lsharp -lc_utils -lfftpack

clean:
	-rm *.o
	-rm *.so

install:
	cp libhealpixwrapper.so ..

