FROM debian:stretch
MAINTAINER Vladimir Smirnov <civil.over@gmail.com>

# Make sure the package repository is up to date.
RUN sed -i 's#http://deb.debian.org#http://cloudfront.debian.net#g' /etc/apt/sources.list
RUN [ -d /etc/apt/sources.list.d/ ] && sed -i 's#http://deb.debian.org#http://cloudfront.debian.net#g' /etc/apt/sources.list.d/* ||:
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y apt-utils wget curl
RUN apt-get install -y git openssh-server libcairo2-dev mercurial build-essential ruby ruby-dev lsb-release
# Install a basic SSH server
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd

# Install Go and other deps
RUN wget -q -O/tmp/go.tar.gz https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz
RUN tar -xf /tmp/go.tar.gz -C /usr/local/
RUN rm -f /tmp/go.tar.gz
RUN gem install fpm

RUN gem install package_cloud

ADD pack.sh /root/
#ADD pack_bintray.sh /home/jenkins/

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
