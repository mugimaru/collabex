RELEASE_VERSION = $(shell grep version mix.exs | sed 's/^.*[^0-9]\([0-9]*\.[0-9]*\.[0-9]*\).*$$/\1/')
DOCKER_REPO ?= ghcr.io/mugimaru
DOCKER_IMAGE = ${DOCKER_REPO}/collabex

build-docker-image:
	mix deps.get
	docker build --build-arg VERSION=$(RELEASE_VERSION) --compress -t ${DOCKER_IMAGE}:$(RELEASE_VERSION) .

push-docker-image:
	docker push ${DOCKER_IMAGE}:${RELEASE_VERSION}

push-docker-latest:
	docker tag ${DOCKER_IMAGE}:${RELEASE_VERSION} ${DOCKER_IMAGE}:latest
	docker push ${DOCKER_IMAGE}:latest