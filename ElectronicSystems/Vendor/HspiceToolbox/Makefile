include ../../../Vendor/common.mk

filename := hspice_toolbox.tar.gz
url := http://www.cppsim.com/InstallFiles/hspice_toolbox.tar.gz

all: $(filename)

$(filename):
	curl $(url) -o $(filename)
	tar -xzf $(filename)
	mv HspiceToolbox/* ./
