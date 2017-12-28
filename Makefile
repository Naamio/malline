clean:
	if	[ -d ".build" ]; then \
		rm -rf .build ; \
	fi

build: clean
	@echo --- Building Malline
	swift --version
	swift build

build-release: clean
	docker run -v $$(pwd):/tmp/malline -w /tmp/malline -it ibmcom/swift-ubuntu:4.1 swift build -c release -Xcc -fblocks -Xlinker -L/usr/local/lib -Xswiftc -whole-module-optimization

test-linux:
	docker run -v $$(pwd):/tmp/malline -w /tmp/malline -it ibmcom/swift-ubuntu:4.1 swift test

test: build
	swift test

.PHONY: build clean test
