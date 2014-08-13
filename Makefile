vendors=Chebfun CustomizableHeatMaps DACE DataHash

all: $(vendors)

$(vendors):
	$(MAKE) -C $@ all

.PHONY: all $(vendors)
