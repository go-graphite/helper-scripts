#!/usr/bin/env bash
export PATH="/root/go/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}"
export GOPATH="/root/go"
[[ -f /etc/extra_opts ]] && . /etc/extra_opts
DISTRO=$(lsb_release -s -i | tr '[:upper:]' '[:lower:]')
# Debian uses 'lsb_release -c' as a repo name
# CentOS and Ubuntu uses 'lsb_release -r'
LSB_R=$(lsb_release -s -r)
LSB_C=$(lsb_release -s -c)
VERSION=""
PKG="deb"
if [[ "${DISTRO}" == "centos" ]]; then
        DISTRO="el"
        VERSION=$(cut -d'.' -f 1 <<< ${LSB_R})
        PKG="rpm"
	if [[ "${VERSION}" -eq 6 ]]; then
		. /etc/profile.d/ruby.sh
		PATH="${PATH}:/opt/rh/ruby193/root/usr/local/bin/:/opt/rh/ruby193/root/usr/bin/"
	fi
else
	lsb_release -i -s | grep -q "Ubuntu"
	if [[ $? -eq 0 ]]; then
		VERSION="${LSB_R}"
	else
		VERSION="${LSB_C}"
	fi
fi

pushd ~/go/src/github.com/go-graphite/${1}/
make clean
git describe --abbrev=6 --dirty --always --tags | grep -q '\-'
if [[ $? -ne 0 ]]; then
        REPOS="stable autobuilds"
fi
REPOS="autobuilds"
git reset --hard
#git pull
rm -f *.rpm
rm -f *.deb
set -e
/bin/bash +x ./contrib/${1}/fpm/create_package_${PKG}.sh
set +e

for r in ${REPOS}; do
	mkdir -p /root/pkg/${DISTRO}/${VERSION}/${r}
	cp ./*.${PKG} /root/pkg/${DISTRO}/${VERSION}/${r}/
done
popd
