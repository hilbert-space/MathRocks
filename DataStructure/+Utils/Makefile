
MEX ?= mex
MEX_FLAGS = CXXFLAGS="$$CXXFLAGS -Wno-incompatible-pointer-types -Wno-deprecated-declarations -fPIC" -lcrypto

all: computeMD5

computeMD5:
	$(MEX) $(MEX_FLAGS) computeMD5.cpp
