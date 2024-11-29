CXXFLAGS ?= -march=native -O3
override CXXFLAGS := $(CXXFLAGS) `gdal-config --cflags`
override LDLIBS  := $(LDLIBS) `gdal-config --libs`

OBJ = main.o \
      LibImages/LibImages.o \
      Utilities/Utilities.o \
      Utilities/Memory.o \
      Utilities/Parameters.o \
      Utilities/Time.o \
      LibHomography/Homography.o \
      LibHomography/Splines.o

homography: $(OBJ)
	$(CXX) $(LDFLAGS) $^ $(LDLIBS) -o $@

clean:
	rm -f homography $(OBJ)

test: homography
	./$^ test_data/input_uint16.tif -h "`cat test_data/hom2.txt`" test_data/out.tif 800 800
	plambda test_data/out.tif test_data/out.jpg / | imprintf "%m\n"
	@echo "TEST: the number above must be between 1.0 and 2.0"


# hack (compatibility flags for badly configured OSX clang)
#
# The following conditional statement appends "-std=c++11" to CXXFLAGS when the
# macro __APPLE__ is defined.  This is useful to circumvent a bug that arises
# when compiling gdal with clang-9 on modern OSX.
ifeq (1,$(shell $(CXX) -x c++ $(CXXFLAGS) -dM -E -</dev/null|grep __APPLE__|cut -c19-))
override CXXFLAGS := $(CXXFLAGS) -std=c++11
endif

