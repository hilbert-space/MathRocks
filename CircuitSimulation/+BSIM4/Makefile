CURRENT_DIR = $(dir $(lastword $(MAKEFILE_LIST)))
INCLUDE_DIR = $(CURRENT_DIR)../../Include/

BSIM4_URL   = http://www-device.eecs.berkeley.edu/~bsim/Files/BSIM4/BSIM470/BSIM470_Code.tar
BSIM4_DIR   = $(CURRENT_DIR)Sources/
BSIM4_ARCH  = $(CURRENT_DIR)BSIM470_Code.tar

MEX ?= mex
MEX_FLAGS = -outdir $(CURRENT_DIR) -I$(CURRENT_DIR) -I$(INCLUDE_DIR) -I$(BSIM4_DIR)

all: computeGeometry

computeGeometry: $(BSIM4_DIR)
	$(MEX) $(MEX_FLAGS) $(CURRENT_DIR)computeGeometry.c $(BSIM4_DIR)b4geo.c

$(BSIM4_DIR): $(BSIM4_ARCH)
	mkdir -p $(BSIM4_DIR)
	tar -xf $(BSIM4_ARCH) -C $(BSIM4_DIR)

$(BSIM4_ARCH):
	wget -O $(BSIM4_ARCH) $(BSIM4_URL)
