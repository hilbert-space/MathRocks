include ../common.mk

filename := heatmaps.zip
url := http://www.mathworks.com/matlabcentral/fileexchange/downloads/514540/download

all: $(filename)

$(filename):
	curl -L $(url) -o $@
	unzip $(filename)
	mv ./heatmaps/* ./
	rmdir ./heatmaps
