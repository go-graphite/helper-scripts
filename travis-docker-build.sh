#!/bin/bash
# centos:6 
OS="centos:7 ubuntu:14.04 ubuntu:16.04 debian:jessie debian:stretch debian:buster"
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
	mkdir -p _pkg
	docker cp ${NAME}:/root/pkg ./_pkg/ || return 1
	docker stop ${NAME}
	docker rm ${NAME}
}

die() {
	echo ${1}
	exit 1
}

if [[ "${BUILD_PACKAGES}" == "true" ]]; then
        if [[ ! -z "${PACKAGECLOUD_TOKEN}" ]]; then
		mkdir -p _pkg/
		for i in ${OS}; do
			docker_build ${i} ${1} &
		done
                gem install package_cloud
                wait
	        pushd _pkg/pkg || die "Failed to 'pushd _pkg/pkg'"
		ls
	        for d in el debian ubuntu; do
	                pushd ${d} || die "Failed to pushd to ${d}"
			echo "d=${d}"
			ls
	                for v in $(ls); do
				echo "  v=${v}"
	                        pushd ${v} || die "Failed to pushd to ${v}"
				ls
	                        for r in $(ls); do
					echo "  r=${r}"
					ls ./${r}/* | grep -q "\(deb\|rpm\)"
					dont_have_pkgs=$?
					if [[ ! -d "${r}" ]] || [[ ${dont_have_pkgs} -ne 0 ]]; then
						continue
					fi
					if [[ "${DRY_RUN}" == "true" ]]; then
						echo "dry_run enabled, won't push anything"
					else
						echo "Will push to 'go-graphite/${r}/${d}/${v}'"
	                                	package_cloud push go-graphite/${r}/${d}/${v} ./${r}/*
					fi
	                        done
				echo "  popd from v=${v}"
	                        popd
	                done
			echo "popd from d=${d}"
	                popd
	        done
		echo "  popd from _pkg/pkg"
	        popd
	fi
fi
