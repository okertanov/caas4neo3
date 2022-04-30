##
## Copyright (c) 2022 - Team11. All rights reserved.
##

##
## Definitions
##

MODULES_DIR=modules
GIT_ROOT=git@github.com:okertanov
GIT_BRANCH=polaris-wip

NEO_MODULES=\
	modules/neo-vm \
	modules/neo \
	modules/neo-modules \
	modules/neo-node \
	modules/neo-devpack-dotnet

NXA_MODULES=\
	modules/nxa-modules \
	modules/nxa-sc-caas \
	modules/nxa-open-api

##
## Initial targets
##

all: bootstrap build

bootstrap: clone

clone: ${NEO_MODULES} ${NXA_MODULES}

##
## NEO_MODULES
##

modules/neo-vm:
	cd ${MODULES_DIR} && git clone ${GIT_ROOT}/neo-vm.git
	cd ${MODULES_DIR}/neo-vm && git checkout ${GIT_BRANCH}

modules/neo:
	cd ${MODULES_DIR} && git clone ${GIT_ROOT}/neo.git
	cd ${MODULES_DIR}/neo && git checkout ${GIT_BRANCH}

modules/neo-modules:
	cd ${MODULES_DIR} && git clone ${GIT_ROOT}/neo-modules.git
	cd ${MODULES_DIR}/neo-modules && git checkout ${GIT_BRANCH}

modules/neo-node:
	cd ${MODULES_DIR} && git clone ${GIT_ROOT}/neo-node.git
	cd ${MODULES_DIR}/neo-node && git checkout ${GIT_BRANCH}

modules/neo-devpack-dotnet:
	cd ${MODULES_DIR} && git clone ${GIT_ROOT}/neo-devpack-dotnet.git
	cd ${MODULES_DIR}/neo-devpack-dotnet && git checkout ${GIT_BRANCH}

##
## NXA_MODULES
##

modules/nxa-modules:
	cd ${MODULES_DIR} && git clone ${GIT_ROOT}/nxa-modules.git
	cd ${MODULES_DIR}/nxa-modules && git checkout ${GIT_BRANCH}

modules/nxa-sc-caas:
	cd ${MODULES_DIR} && git clone ${GIT_ROOT}/nxa-sc-caas.git
	cd ${MODULES_DIR}/nxa-sc-caas && git checkout ${GIT_BRANCH}

modules/nxa-open-api:
	cd ${MODULES_DIR} && git clone ${GIT_ROOT}/nxa-open-api.git
	cd ${MODULES_DIR}/nxa-open-api && git checkout ${GIT_BRANCH}

##
## Common targets
##

build:

clean:

distclean:

.PHONY:

.SILENT: clean distclean
