MEX ?= mex
MEX_FLAGS = CFLAGS="$$CFLAGS -Wno-logical-op-parentheses -Wno-incompatible-pointer-types"

all:
	$(MEX) $(MEX_FLAGS) uninit.c
