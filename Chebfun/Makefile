include ../common.mk

filename := chebfun.zip
url := http://www.chebfun.org/download/chebfun_v4.3.2987.zip

all: $(filename)

$(filename):
	curl $(url) -o $(filename)
	unzip $(filename)
	mv chebfun/* ./
