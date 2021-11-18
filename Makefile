.PHONY: all image push

IMAGE_REGISTRY ?= quay.io/silicom
VERSION 	   ?= v2.0.9-1
BUILDTOOL 	   ?= docker
COMMIT_ID 	   ?= ed354572

IMAGE := $(IMAGE_REGISTRY)/opae-runtime:$(VERSION)-$(COMMIT_ID)

all: image

image:
	$(BUILDTOOL) build . --build-arg COMMIT_ID=$(COMMIT_ID) -t $(IMAGE)

push: image
	$(BUILDTOOL) push $(IMAGE)
