#!/bin/bash -x
OS="centos:6 centos:7 ubuntu:14.04 ubuntu:16.04"

docker_build() {
	NAME="$(sed 's/://g;s/\.//g' <<< ${1})"
        docker pull civilus/gographite-build-${i}

	docker create --name ${NAME} civilus/gographite-build-${1}
	docker start ${NAME}
	docker cp /home/travis/gopath ${NAME}:/root/go
	docker exec ${NAME} '/bin/bash' '/root/pack.sh' "${2}" || return 1
	docker cp ${NAME}:/root/pkg ./ || return 1
	docker rm ${NAME}
}

if [[ "${BUILD_PACKAGES}" == "true" ]]; then
        if [ "$TRAVIS_BRANCH" == "master" ] || [ "${FORCE_BUILD}" == "true" ]; then
		for i in ${OS}; do
			docker_build ${i} ${1} &
		done
                gem install package_cloud
                wait
	        pushd pkg
		ls
	        for d in $(ls); do
	                pushd ${d}
			ls
	                for v in $(ls); do
	                        pushd ${v}
				ls
	                        for r in $(ls); do
	                                package_cloud push go-graphite/${r}/${d}/${v} ./${r}/*
	                        done
	                        popd
	                done
	                popd
	        done
	        popd
	fi
fi
