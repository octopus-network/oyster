#!/usr/bin/make -f

PACKAGES_NOSIMULATION=$(shell go list ./... | grep -v '/simulation')
VERSION ?= $(shell echo $(shell git describe --tags --always) | sed 's/^v//')
TMVERSION := $(shell go list -m github.com/tendermint/tendermint | sed 's:.* ::')
COMMIT := $(shell git log -1 --format='%H')
LEDGER_ENABLED ?= true
OYSTER_BINARY = oysterd
BUILDDIR ?= $(CURDIR)/build

export GO111MODULE = on

# Default target executed when no arguments are given to make.
default_target: build

.PHONY: default_target

# process build tags

build_tags = netgo
ifeq ($(LEDGER_ENABLED),true)
  ifeq ($(OS),Windows_NT)
    GCCEXE = $(shell where gcc.exe 2> NUL)
    ifeq ($(GCCEXE),)
      $(error gcc.exe not installed for ledger support, please install or set LEDGER_ENABLED=false)
    else
      build_tags += ledger
    endif
  else
    UNAME_S = $(shell uname -s)
    ifeq ($(UNAME_S),OpenBSD)
      $(warning OpenBSD detected, disabling ledger support (https://github.com/cosmos/cosmos-sdk/issues/1988))
    else
      GCC = $(shell command -v gcc 2> /dev/null)
      ifeq ($(GCC),)
        $(error gcc not installed for ledger support, please install or set LEDGER_ENABLED=false)
      else
        build_tags += ledger
      endif
    endif
  endif
endif

ifeq (cleveldb,$(findstring cleveldb,$(COSMOS_BUILD_OPTIONS)))
  build_tags += gcc
endif
build_tags += $(BUILD_TAGS)
build_tags := $(strip $(build_tags))

# process linker flags

ldflags = -X github.com/cosmos/cosmos-sdk/version.Name=oyster \
          -X github.com/cosmos/cosmos-sdk/version.AppName=$(OYSTER_BINARY) \
          -X github.com/cosmos/cosmos-sdk/version.Version=$(VERSION) \
          -X github.com/cosmos/cosmos-sdk/version.Commit=$(COMMIT) \
          -X github.com/tendermint/tendermint/version.TMCoreSemVer=$(TMVERSION)

# DB backend selection
ifeq (cleveldb,$(findstring cleveldb,$(COSMOS_BUILD_OPTIONS)))
  ldflags += -X github.com/cosmos/cosmos-sdk/types.DBBackend=cleveldb
endif
ifeq (badgerdb,$(findstring badgerdb,$(COSMOS_BUILD_OPTIONS)))
  ldflags += -X github.com/cosmos/cosmos-sdk/types.DBBackend=badgerdb
endif
# handle rocksdb
ifeq (rocksdb,$(findstring rocksdb,$(COSMOS_BUILD_OPTIONS)))
  CGO_ENABLED=1
  build_tags += rocksdb
  ldflags += -X github.com/cosmos/cosmos-sdk/types.DBBackend=rocksdb
endif
# handle boltdb
ifeq (boltdb,$(findstring boltdb,$(COSMOS_BUILD_OPTIONS)))
  build_tags += boltdb
  ldflags += -X github.com/cosmos/cosmos-sdk/types.DBBackend=boltdb
endif

# add build tags to linker flags
whitespace := $(subst ,, )
comma := ,
build_tags_comma_sep := $(subst $(whitespace),$(comma),$(build_tags))
ldflags += -X "github.com/cosmos/cosmos-sdk/version.BuildTags=$(build_tags_comma_sep)"

ifeq (,$(findstring nostrip,$(COSMOS_BUILD_OPTIONS)))
  ldflags += -w -s
endif
ldflags += $(LDFLAGS)
ldflags := $(strip $(ldflags))

BUILD_FLAGS := -tags "$(build_tags)" -ldflags '$(ldflags)'
# check for nostrip option
ifeq (,$(findstring nostrip,$(COSMOS_BUILD_OPTIONS)))
  BUILD_FLAGS += -trimpath
endif

# check if no optimization option is passed
# used for remote debugging
ifneq (,$(findstring nooptimization,$(COSMOS_BUILD_OPTIONS)))
  BUILD_FLAGS += -gcflags "all=-N -l"
endif

# # The below include contains the tools and runsim targets.
# include contrib/devtools/Makefile

###############################################################################
###                                  Build                                  ###
###############################################################################

BUILD_TARGETS := build install

build: BUILD_ARGS=-o $(BUILDDIR)/
build-linux:
	GOOS=linux GOARCH=amd64 LEDGER_ENABLED=false $(MAKE) build

$(BUILD_TARGETS): go.sum $(BUILDDIR)/
	CGO_ENABLED="1" go $@ $(BUILD_FLAGS) $(BUILD_ARGS) ./...

$(BUILDDIR)/:
	mkdir -p $(BUILDDIR)/

clean:
	rm -rf \
    $(BUILDDIR)/ \
    artifacts/ \
    tmp-swagger-gen/

.PHONY: clean build

###############################################################################
###                                Localnet                                 ###
###############################################################################

# Build image for a local testnet
localnet-build:
	docker build --no-cache --tag oyster/node -f Dockerfile .

# Start a 4-node testnet locally
localnet-start: localnet-stop localnet-build
	@if ! [ -f build/node0/$(OYSTER_BINARY)/config/genesis.json ]; then docker run --rm -v $(CURDIR)/build:/oyster:Z oyster/node "./oysterd testnet init-files --chain-id oyster_9100-1 --v 4 -o /oyster --keyring-backend=test --starting-ip-address 192.167.10.2 --node-daemon-home=oysterd"; fi
	docker compose up -d

# Stop testnet
localnet-stop:
	docker compose down

# Clean testnet
localnet-clean:
	docker compose down
	sudo rm -rf build/*

# Show logs
localnet-show-logstream:
	docker compose logs --tail=1000 -f

.PHONY: localnet-build localnet-start localnet-stop