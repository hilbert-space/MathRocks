vendors=$(patsubst ./%,%,$(shell find . -maxdepth 1 ! -path . -type d))

all: $(vendors)

$(vendors):
	$(MAKE) -C $@ all

clean: $(addprefix clean_,$(vendors))

clean_%:
	$(MAKE) -C $* clean

.PHONY: all $(vendors) clean clean_*
