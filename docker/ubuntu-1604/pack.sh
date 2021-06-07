#!/usr/bin/env bash
TYPE="${1}"
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
REPOS="autobuilds"

git describe --abbrev=6 --dirty --always --tags | grep -q '^v[0-9]\+\.[0-9]\+\(\.[0-9]\+\)\?$'
if [[ $? -eq 0 ]]; then
        REPOS="stable autobuilds"
fi
git reset --hard
rm -f *.rpm
rm -f *.deb
set -e
/bin/bash -x /root/create_package_${PKG}.sh
set +e

for r in ${REPOS}; do
        mkdir -p /root/pkg/${DISTRO}/${VERSION}/${r}
        cp /root/*.${PKG} /root/pkg/${DISTRO}/${VERSION}/${r}/
done
popd
