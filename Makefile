# Makefile
build:
	@echo --- Building Malline
	swift build

.PHONY: run

test: build
	swift test
