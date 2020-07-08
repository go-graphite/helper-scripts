#!/bin/bash -x
die() {
    if [[ $1 -eq 0 ]]; then
        rm -rf "${TMPDIR}"
    else
        echo "Temporary data stored at '${TMPDIR}'"
    fi
    echo "$2"
    exit $1
}

pwd

VERSION=""
RELEASE=""
COMMIT=""
ARCH=$(uname -m)
VERSION_GIT=$(git describe --abbrev=6 --always --tags)
PKG_VERSION=""
case ${VERSION_GIT} in
    *-alpha*|*-beta*|*-rc*)
        VERSION=$(cut -d'-' -f 1 <<< ${VERSION_GIT})
        RELEASE=$(cut -d'-' -f 2 <<< ${VERSION_GIT})
        RELEASE2=$(cut -d'-' -f 3 <<< ${VERSION_GIT})
        COMMIT=$(cut -d'-' -f 4 <<< ${VERSION_GIT})
        if [[ -z "${RELEASE}" ]] || [[ ${RELEASE} == 0 ]]; then
            RELEASE="1"
        fi
        export MY_APP_VERSION="v${VERSION}-${RELEASE}"
        PKG_VERSION="${VERSION}-${RELEASE}"
        if [[ ! -z "${COMMIT}" ]]; then
            export MY_APP_VERSION="${MY_APP_VERSION}.${RELEASE2}+sha.${COMMIT}"
            PKG_VERSION="${PKG_VERSION}.${RELEASE2}.${COMMIT}"
        fi

    ;;
    *)
        VERSION_GIT=$(rev <<< "${VERSION_GIT}" | sed 's/-/./' | rev)
        VERSION=$(cut -d'-' -f 1 <<< ${VERSION_GIT})
        RELEASE=$(cut -d'-' -f 2 <<< ${VERSION_GIT} | cut -d'.' -f 1)
        COMMIT=$(cut -d'.' -f 4 <<< ${VERSION_GIT})
        if [[ -z "${RELEASE}" ]] || [[ ${RELEASE} == 0 ]]; then
            RELEASE="1"
        fi
        export MY_APP_VERSION="v${VERSION}-${RELEASE}"
        PKG_VERSION="${VERSION}-${RELEASE}"
        if [[ ! -z "${COMMIT}" ]]; then
            export MY_APP_VERSION="${MY_APP_VERSION}+sha.${COMMIT}"
            PKG_VERSION="${PKG_VERSION}.${COMMIT}"
        fi
    ;;
esac

grep '^[0-9]\+\.[0-9]\+' <<< ${VERSION} || {
        echo "Revision: $(git rev-parse HEAD)";
        echo "Version: $(git describe --abbrev=6 --always --tags)";
	echo "Parsed version: ${VERSION}"
	echo "Parsed release: ${RELEASE}"
	echo "Parsed commit: ${COMMIT}"
        echo "Known tags: $(git tag)";
        echo;
        echo;
        die 1 "Can't get latest version from git";
}

TMPDIR=$(mktemp -d)

make || die 1 "Can't build package"
make DESTDIR="${TMPDIR}" install || die 1 "Can't install package"
mkdir -p "${TMPDIR}"/etc/systemd/system/
mkdir -p "${TMPDIR}"/etc/sysconfig/
cp ./contrib/carbonapi/rhel/carbonapi.service "${TMPDIR}"/etc/systemd/system/
cp ./contrib/carbonapi/common/carbonapi.env "${TMPDIR}"/etc/sysconfig/carbonapi

pushd "${TMPDIR}"
/root/go/bin/nfpm -f /root/nfpm.yaml pkg --target "/root/carbonapi-${PKG_VERSION}.${ARCH}.rpm" || die "Can't create package!"
#mv "carbonapi-${VERSION}-${RELEASE}.${ARCH}.rpm" /root/
popd

die 0 "Success"
