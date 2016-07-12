include ../../../Vendor/common.mk

filename := cprintf.zip
url := http://www.mathworks.com/matlabcentral/fileexchange/downloads/395121/download

all: $(filename)

$(filename):
	curl -L $(url) -o $(filename)
	unzip $(filename)
