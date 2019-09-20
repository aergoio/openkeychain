.PHONY: help all build test clean

all: build test

help:
	@echo "Targets:"
	@echo "  help"
	@echo "  all"
	@echo "  build"
	@echo "  test"
	@echo "  clean"


DIR_TARGET = target
BUNDLE = $(DIR_TARGET)/openkeychain.lua
BINARY = $(DIR_TARGET)/openkeychain.bin
SOURCE = $(wildcard src/main/lua/*.lua)
DIR_BRICK = src/test/brick
TEST_BRICK = $(wildcard $(DIR_BRICK)/test-*.brick)


build: target compile

target:
	@mkdir -p $(DIR_TARGET)

compile: $(BUNDLE) $(BINARY)

$(BUNDLE): target $(SOURCE)
	ship build

$(BINARY): target $(BUNDLE)
	aergoluac --payload $(BUNDLE) > $(BINARY)

clean:
	@rm -rf $(DIR_TARGET)

test: build brick



.PHONY: brick test- test-% FORCE 

brick: $(TEST_BRICK)

%.brick: FORCE
	brick $@

test-%: FORCE
	brick $(DIR_BRICK)/$@.brick -v

test-: test

FORCE: ;
