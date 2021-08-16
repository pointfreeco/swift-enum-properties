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
	cp ./.xcode/*.codesnippet $(SNIPDIR)

$(SNIPDIR):
	mkdir -p $(SNIPDIR)

test: test-linux test-swift

test-linux:
	docker run \
		--rm \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		swift:5.1 \
		bash -c 'make test-swift'

test-swift:
	swift test \
		--enable-test-discovery \
		--parallel

.PHONY: uninstall snippets test-linux test-swift
