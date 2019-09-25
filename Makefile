BINARY = generate-enum-properties
BUILD = .build/release/$(BINARY)
BINDIR = $(PREFIX)/bin
INSTALL = $(BINDIR)/$(BINARY)
PREFIX = /usr/local
SNIPDIR = $(HOME)/Library/Developer/Xcode/UserData/CodeSnippets/
SOURCES = $(wildcard Sources/**/*.swift)

build: $(BUILD)

install: $(INSTALL)

uninstall:
	rm -f $(INSTALL)

$(INSTALL): $(BUILD)
	mkdir -p $(BINDIR)
	cp -f $(BUILD) $(INSTALL)

$(BUILD): $(SOURCES)
	swift build \
		--configuration release \
		--disable-sandbox \

snippets: $(SNIPDIR)
	cp ./.xcode/*.xml $(SNIPDIR)

$(SNIPDIR):
	mkdir -p $(SNIPDIR)

test: test-linux test-macos

test-linux:
	swift test --generate-linuxmain
	docker build --tag enum-properties-testing . \
		&& docker run --rm enum-properties-testing

test-macos:
	swift test

.PHONY: uninstall snippets test-linux test-macos
