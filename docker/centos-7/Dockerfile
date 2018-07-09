FROM centos:7
MAINTAINER Vladimir Smirnov <civil.over@gmail.com>

# Make sure the package repository is up to date.
RUN yum upgrade -y
RUN yum install -y git openssh cairo-devel mercurial ruby-devel wget redhat-lsb-core openssh-server
RUN yum groupinstall -y 'Development Tools'

# Install Go and other deps
RUN wget -q -O/tmp/go.tar.gz https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz
RUN tar -xf /tmp/go.tar.gz -C /usr/local/
RUN rm -f /tmp/go.tar.gz
RUN gem install fpm

# PackageCloud
RUN gem install package_cloud

ADD pack.sh /root
# Bintray
#ADD pack_bintray.sh /root

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
