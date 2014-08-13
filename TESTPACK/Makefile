define files
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

files := $(shell echo $(files) | tr -d '\n')

all: $(files)

$(files):
	curl http://people.sc.fsu.edu/~jburkardt/m_src/testpack/$@ -O
