SHELL := /bin/bash

build:
	docker build -f Dockerfile-base -t guadaltech/app-gobierto-base:latest .

push:
	gcloud docker -- push guadaltech/app-gobierto-base:latest
 