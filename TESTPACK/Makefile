include ../common.mk

define filenames
	adapt.m
	genz_function.m
	genz_integral.m
	genz_name.m
	genz_phi.m
	genz_random.m
	multst.m
	r8_epsilon.m
	r8vec_median.m
	testpack.m
	timestamp.m
	tuple_next.m
endef

url := http://people.sc.fsu.edu/~jburkardt/m_src/testpack
filenames := $(shell echo $(filenames) | tr -d '\n')

all: $(filenames)

$(filenames):
	curl $(url)/$@ -O
