FROM debian:bullseye
MAINTAINER Vladimir Smirnov <civil.over@gmail.com>

# Make sure the package repository is up to date.
ARG CACHE_DATE=20221004
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y wget curl apt-utils git openssh-server libcairo2-dev mercurial build-essential lsb-release
RUN mkdir -p /var/run/sshd

# Install Go and other deps
RUN wget -q -O/tmp/go.tar.gz https://go.dev/dl/go1.19.2.linux-amd64.tar.gz
RUN tar -xf /tmp/go.tar.gz -C /usr/local/
RUN rm -f /tmp/go.tar.gz
RUN mkdir -p /root/go
RUN rm -rf /root/go/src

# Install nfpm
ENV PATH="${PATH}:/usr/local/go/bin"
RUN wget -q -O/tmp/nfpm.tar.gz https://github.com/goreleaser/nfpm/releases/download/v2.15.1/nfpm_2.15.1_Linux_x86_64.tar.gz
RUN tar -xf /tmp/nfpm.tar.gz -C /usr/local/bin
RUN nfpm -v

ADD pack.sh /root
ADD create_package_deb.sh /root
ADD nfpm.yaml /root

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
