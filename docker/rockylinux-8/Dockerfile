FROM rockylinux:8
MAINTAINER Vladimir Smirnov <civil.over@gmail.com>

# Make sure the package repository is up to date.
ARG CACHE_DATE=20230827
RUN yum upgrade -y
RUN yum install -y openssh-server
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
RUN ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa
RUN ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519

RUN yum upgrade -y
RUN yum install -y git openssh cairo-devel mercurial ruby-devel wget redhat-lsb-core
RUN yum groupinstall -y 'Development Tools'

# Install Go and other deps
RUN wget -q -O/tmp/go.tar.gz https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
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
ADD create_package_rpm.sh /root
ADD nfpm.yaml /root

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
