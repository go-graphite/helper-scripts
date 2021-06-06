#!/bin/bash
set -e
OS="ubuntu:16.04 ubuntu:18.04 ubuntu:20.04 debian:stretch debian:buster debian:bullseye centos:8 centos:7"
SQUASH=false
for i in ${OS}; do
	folder=$(sed 's/:/-/g;s/\.//g' <<< ${i})
	echo "Building for $folder"
	if [[ "${SQUASH}" == "true" ]]; then
		docker build -t civilus/gographite-build-tmp-${i} ./${folder}/
		ID=$(docker image inspect civilus/gographite-build-tmp-${i} | jq '.[0]["Id"]' | cut -d: -f 2 | cut -d'"' -f 1)
		docker save ${ID} | /root/go/bin/docker-squash -t civilus/gographite-build-${i} -verbose | docker load
	else
		docker build -t ghcr.io/go-graphite/go-graphite-build-${i} ./${folder}/
	fi
	docker push ghcr.io/go-graphite/go-graphite-build-${i}
done
