RELEASE_VERSION = $(shell grep version mix.exs | sed 's/^.*[^0-9]\([0-9]*\.[0-9]*\.[0-9]*\).*$$/\1/')
DOCKER_REPO ?= mugimaru

build-docker-image:
	mix deps.get
	docker build --build-arg VERSION=$(RELEASE_VERSION) --squash --compress -t collabex:$(RELEASE_VERSION) .

push-docker-image:
	docker tag collabex:$(RELEASE_VERSION) ${DOCKER_REPO}/collabex:$(RELEASE_VERSION)
	docker push ${DOCKER_REPO}/collabex:${RELEASE_VERSION}