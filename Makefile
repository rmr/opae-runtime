.PHONY: all image push

IMAGE_REGISTRY ?= quay.io/ryan_raasch
VERSION ?= v2.0.6-1
BUILDTOOL ?= docker

IMAGE := $(IMAGE_REGISTRY)/opae-runtime:$(VERSION)

all: image

image:
	$(BUILDTOOL) build . $(BUILD_ARGS) -t $(IMAGE)

push: image
	$(BUILDTOOL) push $(IMAGE)
