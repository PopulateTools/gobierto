SHELL := /bin/bash

build:
	docker build -f Dockerfile-base -t guadaltech/gobierto-base:latest .

push:
	gcloud docker -- push guadaltech/gobierto-base:latest
 