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
## NEO Infra
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
## NXA Infra
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

build: \
	build-modules-neo-vm \
	build-modules-neo \
	build-modules-neo-modules \
	build-modules-neo-node \
	build-modules-neo-devpack-dotnet \
	build-modules-nxa-sc-caas \
	build-modules-nxa-modules \
	build-modules-nxa-open-api

build-modules-neo-vm: modules/neo-vm
	make -C $< build

build-modules-neo: modules/neo
	make -C $< build

build-modules-neo-modules: modules/neo-modules
	make -C $< build

build-modules-neo-node: modules/neo-node
	make -C $< build

build-modules-neo-devpack-dotnet: modules/neo-devpack-dotnet
	make -C $< build

build-modules-nxa-modules: modules/nxa-modules
	make -C $< build

build-modules-nxa-sc-caas: modules/nxa-sc-caas
	make -C $< build

build-modules-nxa-open-api: modules/nxa-open-api
	make -C $< build

##
## Docker targets
##

PROJECT_NAME=neo-testnet-node
HUB_REGISTRY_NAME=${PROJECT_NAME}
HUB_REGISTRY_USER=okertanov
HUB_REGISTRY_TOKEN=5bd37ac1-045d-4923-8c94-b0f9fbfbe19b

docker-build:
	docker-compose build --parallel

docker-rebuild:
	docker-compose build --parallel --force-rm --pull

docker-start:
	docker-compose up -d

docker-stop:
	docker-compose down --remove-orphans

docker-exec:
	ifeq ($(OS),Windows_NT)
		winpty docker-compose exec ${PROJECT_NAME} sh || true
	else
		docker-compose exec ${PROJECT_NAME} sh || true
	endif

docker-clean: docker-stop
	-@docker container prune --force
	-@docker image prune --all --force

##
## Publish targets
##

docker-publish: docker-build
	@echo ${HUB_REGISTRY_TOKEN} | docker login --username ${HUB_REGISTRY_USER} --password-stdin
	docker tag ${PROJECT_NAME}:latest ${HUB_REGISTRY_USER}/${HUB_REGISTRY_NAME}:latest
	docker push ${HUB_REGISTRY_USER}/${HUB_REGISTRY_NAME}:latest

##
## Deployment targets
##

deploy-public: SSH?=team11@neo-testnet-public.lan
deploy-public: docker-compose.gcp.testnet-public.yml docker-publish
	ssh ${SSH} mkdir -p ./deployment/${PROJECT_NAME}/config/testnet
	scp Makefile ${SSH}:./deployment/${PROJECT_NAME}/
	scp .env ${SSH}:./deployment/${PROJECT_NAME}/
	scp $< ${SSH}:./deployment/${PROJECT_NAME}/
	scp -pr config/testnet/public ${SSH}:./deployment/${PROJECT_NAME}/config/testnet/
	ssh ${SSH} \
		"cd ./deployment/${PROJECT_NAME}/ && \
			docker-compose -f $< down"
	ssh ${SSH} \
		"cd ./deployment/${PROJECT_NAME}/ && \
			docker-compose -f $< pull"
	ssh ${SSH} \
		"cd ./deployment/${PROJECT_NAME}/ && \
			docker-compose -f $< up -d"
	ssh ${SSH} docker ps

##
## Cleanups targets
##

clean:
	-@make -C modules/neo-vm clean
	-@make -C modules/neo clean
	-@make -C modules/neo-modules clean
	-@make -C modules/neo-node clean
	-@make -C modules/neo-devpack-dotnet clean
	-@make -C modules/nxa-modules clean
	-@make -C modules/nxa-sc-caas clean
	-@make -C modules/nxa-open-api clean

distclean: clean

##
## Internal targets
##

.PHONY: all bootstrap clone build clean distclean \
	docker-build docker-rebuild \
	docker-start docker-stop docker-exec \
	docker-clean docker-publish deploy-public

.SILENT: clean distclean
