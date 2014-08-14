.DEFAULT_GOAL := all

clean:
	find . -maxdepth 1 ! -name Makefile ! -path . -print0 | xargs -0 rm -rf

.PHONY: all clean
