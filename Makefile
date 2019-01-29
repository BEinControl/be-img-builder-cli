.PHONY: help list build up down rebuild clean start status ps logs stop restart sh bash shell image

APP_NAME := be-builder

DOCKER         := docker
DOCKER_COMPOSE := docker-compose

CMD_IMAGE     := /usr/bin/make
CMD_SHELL     := /bin/bash

.DEFAULT_GOAL := help

ME  := $(realpath $(firstword $(MAKEFILE_LIST)))
PWD := $(dir $(ME))

DOCKER_COMPOSE_FILE := $(PWD)/docker/docker-compose.yml

c      ?= ""
client ?= $(c)
CLIENT ?= $(client)

d      ?= ""
device ?= $(d)
DEVICE ?= $(device)

##
# help
# Displays list of targets, using target '##' comments as descriptions
# NOTE: Keep 'help' as first target in case .DEFAULT_GOAL is not honored
#
help:      ## This help screen
	@echo
	@echo  "Make targets:"
	@echo
	@cat $(ME) | \
	sed -n -E 's/^([^.][^: ]+)\s*:(([^=#]*##\s*(.*[^[:space:]])\s*)|[^=].*)$$/    \1	\4/p' | \
	sort -u | \
	expand -t15
	@echo

##
# list
# We place 'list' after 'help' to keep 'help' as first target
#
list: help ## List targets (currently an alias for 'help')

##
# build
#
build: ## Build the app
	$(DOCKER_COMPOSE) -f "$(DOCKER_COMPOSE_FILE)" build

##
# up
#
up: ## Launch the app in detached mode
	$(DOCKER_COMPOSE) -f "$(DOCKER_COMPOSE_FILE)" up --detach

##
# down
#
down: ## Stop the app, destroying the container, but preserving images and volumes
	$(DOCKER_COMPOSE) -f "$(DOCKER_COMPOSE_FILE)" down

##
# rebuild
#
rebuild: down build ## Stop the app (if running), and issue a build

##
# clean
#
clean: ## Stop the app, destroying the container, images and volumes
	$(DOCKER_COMPOSE) -f "$(DOCKER_COMPOSE_FILE)" down --volumes --rmi all

##
# start
#
start: ## Start a stopped app
	$(DOCKER_COMPOSE) -f "$(DOCKER_COMPOSE_FILE)" start

##
# ps
#
status: ps ## Alias for 'ps'
ps:        ## Show app status
	$(DOCKER_COMPOSE) -f "$(DOCKER_COMPOSE_FILE)" ps

##
# logs
#
logs:  ## View output of a running app
	$(DOCKER_COMPOSE) -f "$(DOCKER_COMPOSE_FILE)" logs --follow

##
# stop
#
stop: ## Stop a running app, without destroying it
	$(DOCKER_COMPOSE) -f "$(DOCKER_COMPOSE_FILE)" stop

##
# restart
#
restart: stop start ## Stop the app, if running, then start it

##
# shell
#
sh:    shell ## Alias for 'shell'
bash:  shell ## Alias for 'shell' (may not actually be bash)
shell: up    ## Access shell in app container
	$(DOCKER) exec -it $(APP_NAME) $(CMD_SHELL)

##
# image
#
image: up ## Build an image. usage: c|client|CLIENT=<client> d|device|DEVICE=<device>
ifeq ($(CLIENT),"")
	$(error ERROR: 'client' is not set.  Please provide 'c|client|CLIENT=' argument)
endif

ifeq ($(DEVICE),"")
	$(error ERROR: 'device' is not set.  Please provide 'd|device|DEVICE=' argument)
endif

	$(DOCKER) exec -it $(APP_NAME) $(CMD_IMAGE) image CLIENT="$(CLIENT)" DEVICE="$(DEVICE)"
