.PHONY: all image push

IMAGE_REGISTRY ?= quay.io/silicom
BUILDTOOL 	   ?= podman

OPAE_ATOM := https://github.com/OPAE/opae-sdk/releases.atom
OPAE_VERSION := $(shell curl -sL $(OPAE_ATOM) | sed -e 's/xmlns="[^"]*"//g' | xmllint --xpath 'string(//entry/title)' - | sort | tail -n1)
IMAGE := $(IMAGE_REGISTRY)/opae-runtime:$(OPAE_VERSION)

all: image

image:
	$(BUILDTOOL) build . --build-arg OPAE_VERSION=$(OPAE_VERSION) -t $(IMAGE)

check:
	skopeo inspect docker://$(IMAGE)

push:
	$(BUILDTOOL) push $(IMAGE)
