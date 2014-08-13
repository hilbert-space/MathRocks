all: Chebfun

Chebfun:
	curl http://www.chebfun.org/download/chebfun_v4.3.2987.zip -O
	unzip chebfun_v4.3.2987.zip
	mv chebfun Cheb
	mv Cheb Chebfun

.PHONY: all
