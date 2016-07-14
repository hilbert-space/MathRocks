include ../common.mk

url := http://www2.imm.dtu.dk/pubdb/views/edoc_download.php/1460/zip/imm1460.zip
filename := dace.zip

all: $(filename)

$(filename):
	curl $(url) -o $(filename)
	unzip $(filename)
	mv ./dace/* ./
