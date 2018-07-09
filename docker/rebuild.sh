#!/bin/bash
set -e
#OS="centos:7"
#OS="debian:jessie debian:stretch debian:buster"
OS="centos:6 centos:7 ubuntu:14.04 ubuntu:16.04 debian:jessie debian:stretch debian:buster"
SQUASH=false
for i in ${OS}; do
	folder=$(sed 's/:/-/g;s/\.//g' <<< ${i})
	echo "Building for $folder"
	if [[ "${SQUASH}" == "true" ]]; then
		docker build -t civilus/gographite-build-tmp-${i} ./${folder}/
		ID=$(docker image inspect civilus/gographite-build-tmp-centos:6 | jq '.[0]["Id"]' | cut -d: -f 2 | cut -d'"' -f 1)
		docker save ${ID} | /root/go/bin/docker-squash -t civilus/gographite-build-${i} -verbose | docker load
	else
		docker build -t civilus/gographite-build-${i} ./${folder}/
	fi
	docker push civilus/gographite-build-${i}
done
