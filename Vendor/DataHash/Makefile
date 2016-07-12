include ../common.mk

url := http://mathworks.com/matlabcentral/fileexchange/submissions/31272/v/4/download/zip
filename := DataHash.zip

all: $(filename)

$(filename):
	curl -L $(url) -o $(filename)
	unzip $(filename)
