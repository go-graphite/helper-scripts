FROM debian:buster
MAINTAINER Vladimir Smirnov <civil.over@gmail.com>

# Make sure the package repository is up to date.
ARG CACHE_DATE=20200708
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y wget curl apt-utils git openssh-server libcairo2-dev mercurial build-essential lsb-release
RUN mkdir -p /var/run/sshd

# Install Go and other deps
RUN wget -q -O/tmp/go.tar.gz https://dl.google.com/go/go1.14.4.linux-amd64.tar.gz
RUN tar -xf /tmp/go.tar.gz -C /usr/local/
RUN rm -f /tmp/go.tar.gz

# RUN gem install package_cloud

# Install nfpm
ENV PATH="${PATH}:/usr/local/go/bin"
RUN go get -u github.com/goreleaser/nfpm/cmd/nfpm
RUN rm -rf /root/go/src

ADD pack.sh /root
ADD create_package_deb.sh /root
ADD nfpm.yaml /root

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
