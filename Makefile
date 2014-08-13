all: Chebfun CustomizableHeatMaps

Chebfun:
	curl http://www.chebfun.org/download/chebfun_v4.3.2987.zip -O
	unzip chebfun_v4.3.2987.zip
	mv chebfun Cheb
	mv Cheb Chebfun

CustomizableHeatMaps:
	curl http://www.mathworks.com/matlabcentral/fileexchange/downloads/514540/akamai/heatmaps.zip -O
	unzip heatmaps.zip -d CustomizableHeatMaps
	mv CustomizableHeatMaps/heatmaps/* CustomizableHeatMaps/

.PHONY: all
