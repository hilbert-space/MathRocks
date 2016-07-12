include ../common.mk

filename := heatmaps.zip
url := http://mathworks.com/matlabcentral/fileexchange/submissions/24253/v/6/download/zip

all: $(filename)

$(filename):
	curl -L $(url) -o $@
	unzip $(filename)
