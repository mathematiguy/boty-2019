DOCKER_REGISTRY := docker.dragonfly.co.nz
IMAGE_NAME := $(shell basename `git rev-parse --show-toplevel` | tr '[:upper:]' '[:lower:]')
IMAGE := $(DOCKER_REGISTRY)/$(IMAGE_NAME)
RUN ?= docker run $(DOCKER_ARGS) --rm -v $$(pwd):/work -w /work -u $(UID):$(GID) $(IMAGE)
UID ?= $(shell id -u)
GID ?= $(shell id -g)
DOCKER_ARGS ?= 
GIT_TAG ?= $(shell git log --oneline | head -n1 | awk '{print $$1}')

notebooks: $(shell find notebooks -name "*.Rmd" | sed "s/\.Rmd/.pdf/g" | grep -v ".#")

images: data/boty.json
	$(RUN) python3 scripts/download_images.py $<

crawl: data/boty.json
data/boty.json:
	$(RUN) bash -c 'cd boty && scrapy crawl manu -o data/boty.json'

data: data/BOTY-votes-2019.csv
data/BOTY-votes-2019.csv:
	wget https://www.dragonfly.co.nz/data/boty/BOTY-votes-2019.csv -P data

%.pdf: %.Rmd
	$(RUN) Rscript -e 'rmarkdown::render("$*.Rmd")'

clean:
	rm -f notebooks/*.html notebooks/*.pdf notebooks/*-self.bib notebooks/*.log \
	notebooks/bird-of-the-year-2019.tex data/*.json data/*.urls

.PHONY: docker
docker:
	docker build --tag $(IMAGE):$(GIT_TAG) .
	docker tag $(IMAGE):$(GIT_TAG) $(IMAGE):latest

.PHONY: docker-push
docker-push:
	docker push $(IMAGE):$(GIT_TAG)
	docker push $(IMAGE):latest

.PHONY: docker-pull
docker-pull:
	docker pull $(IMAGE):$(GIT_TAG)
	docker tag $(IMAGE):$(GIT_TAG) $(IMAGE):latest

.PHONY: enter
enter: DOCKER_ARGS=-it
enter:
	$(RUN) bash

.PHONY: enter-root
enter-root: DOCKER_ARGS=-it
enter-root: UID=root
enter-root: GID=root
enter-root:
	$(RUN) bash

.PHONY: inspect-variables
inspect-variables:
	@echo DOCKER_REGISTRY: $(DOCKER_REGISTRY)
	@echo IMAGE_NAME:      $(IMAGE_NAME)
	@echo IMAGE:           $(IMAGE)
	@echo RUN:             $(RUN)
	@echo UID:             $(UID)
	@echo GID:             $(GID)
	@echo DOCKER_ARGS:     $(DOCKER_ARGS)
	@echo GIT_TAG:         $(GIT_TAG)
