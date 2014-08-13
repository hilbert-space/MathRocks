vendors=Chebfun CustomizableHeatMaps DACE DataHash SANDIA_RULES

all: $(vendors)

$(vendors):
	$(MAKE) -C $@ all

.PHONY: all $(vendors)
