vendors=$(shell find . -maxdepth 1 ! -path . -type d)

all: $(vendors)

$(vendors):
	$(MAKE) -C $@ all

.PHONY: all $(vendors)
