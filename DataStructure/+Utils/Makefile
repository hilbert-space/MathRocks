MEX ?= mex
MEXFLAGS := CXXFLAGS="$$CXXFLAGS -Wno-incompatible-pointer-types -Wno-deprecated-declarations -fPIC" -lcrypto

all: computeMD5

computeMD5:
	$(MEX) $(MEXFLAGS) computeMD5.cpp
