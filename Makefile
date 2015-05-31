IMAGE := shouldbee/chakram

build:
	sudo docker build -t $(IMAGE) .

destroy:
	sudo docker rmi $(IMAGE)

login:
	sudo docker run -it --rm --net host -v `pwd`:/wd -w /wd --entrypoint=/bin/bash shouldbee/chakram
