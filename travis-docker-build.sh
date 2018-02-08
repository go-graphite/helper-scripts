#!/bin/bash
OS="centos:6 centos:7 ubuntu:14.04 ubuntu:16.04 debian:jessie debian:stretch debian:buster"
if [[ "${DRY_RUN}" == "true" ]]; then
	OS="ubuntu:16.04"
fi

docker_build() {
	NAME="$(sed 's/://g;s/\.//g' <<< ${1})"
        docker pull civilus/gographite-build-${i}

	docker create --name ${NAME} civilus/gographite-build-${1}
	docker start ${NAME}
	docker cp /home/travis/gopath ${NAME}:/root/go
	docker exec ${NAME} '/bin/bash' '-x' '/root/pack.sh' "${2}" || return 1
	docker cp ${NAME}:/root/pkg ./ || return 1
	docker stop ${NAME}
	docker rm ${NAME}
}

if [[ "${BUILD_PACKAGES}" == "true" ]]; then
        if [[ ! -z "${PACKAGECLOUD_TOKEN}" ]]; then
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
					ls ./${r}/* | grep -q "\(deb\|rpm\)"
					dont_have_pkgs=$?
					if [[ ! -d "${r}" ]] || [[ ${dont_have_pkgs} -ne 0 ]]; then
						continue
					fi
					if [[ "${DRY_RUN}" == "true" ]]; then
						echo "dry_run enabled, won't push anything"
					else
	                                	package_cloud push go-graphite/${r}/${d}/${v} ./${r}/*
					fi
	                        done
	                        popd
	                done
	                popd
	        done
	        popd
	fi
fi
