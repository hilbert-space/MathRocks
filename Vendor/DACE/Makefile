include ../common.mk

url := http://www.imm.dtu.dk/~hbni/dace/imm1460.zip
filename := dace.zip

all: $(filename)

$(filename):
	curl $(url) -o $(filename)
	unzip $(filename)
	mv ./dace/* ./
