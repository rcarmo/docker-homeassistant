export IMAGE_NAME=rcarmo/homeassistant
export ARCH?=$(shell arch)
ifneq (,$(findstring arm,$(ARCH)))
export ARCH=armhf
endif
export BASE=rcarmo/ubuntu-python:3.6.3-$(ARCH)
export HOSTNAME?=homeassistant
export DATA_FOLDER=$(HOME)/.homeassistant
export VCS_REF=`git rev-parse --short HEAD`
export VCS_URL=https://github.com/rcarmo/docker-homeassistant
export BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`

build: Dockerfile
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VCS_URL=$(VCS_URL) \
		--build-arg BASE=$(BASE) \
		-t $(IMAGE_NAME):$(ARCH) .

push:
	docker push $(IMAGE_NAME)

network:
	-docker network create -d macvlan \
	--subnet=192.168.1.0/24 \
        --gateway=192.168.1.254 \
	--ip-range=192.168.1.128/25 \
	-o parent=eth0 \
	lan

shell:
	docker run --net=lan -h $(HOSTNAME) -it $(IMAGE_NAME):$(ARCH) /bin/sh

test: 
	docker run -v $(DATA_FOLDER):/home/user/.homeassistant \
		--net=host -h $(HOSTNAME) $(IMAGE_NAME):$(ARCH)

daemon: 
	-mkdir -p $(DATA_FOLDER)
	docker run -v $(DATA_FOLDER):/home/user/.homeassistant \
		--name homeassistant \
		--net=host -h $(HOSTNAME) -d --restart unless-stopped $(IMAGE_NAME):$(ARCH)

clean:
	-docker rm -v $$(docker ps -a -q -f status=exited)
	-docker rmi $$(docker images -q -f dangling=true)
	-docker rmi $$(docker images --format '{{.Repository}}:{{.Tag}}' | grep '$(IMAGE_NAME)')
