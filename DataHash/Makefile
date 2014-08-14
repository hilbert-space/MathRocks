include ../common.mk

url := http://www.mathworks.com/matlabcentral/fileexchange/downloads/376978/download
filename := DataHash.zip

all: $(filename)

$(filename):
	curl -L $(url) -o $(filename)
	unzip $(filename)
