.PHONY: all image push

IMAGE_REGISTRY ?= quay.io/ryan_raasch
PODMAN ?= docker
CLI_EXEC ?= bin/oc

BUILD_ARGS_RHEL82 = --build-arg CENTOS_VER=docker.io/centos:8.2.2004
BUILD_ARGS_RHEL83 = --build-arg CENTOS_VER=docker.io/centos:8.3.2011
RHEL_VER ?= rhel82

BUILD_ARGS := $(BUILD_ARGS_RHEL83)

VERSION ?= v2.0.0
BUILDTOOL ?= podman
IMAGE_NAME := opae

IMAGE := $(IMAGE_REGISTRY)/$(IMAGE_NAME):$(VERSION)

all: image

image:
	$(BUILDTOOL) build . $(CONTAINER_BUILD_ARGS) -t $(IMAGE)

push: image
	$(BUILDTOOL) push $(IMAGE) $(CONTAINER_PUSH_ARGS)
