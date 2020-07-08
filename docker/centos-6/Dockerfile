FROM centos:6
MAINTAINER Vladimir Smirnov <civil.over@gmail.com>

# Make sure the package repository is up to date.
ARG CACHE_DATE=20200708
RUN yum upgrade -y

RUN yum -y groupinstall "Development Tools"
RUN yum -y install tar which git openssh mercurial wget redhat-lsb-core openssh-server

# Install Ruby and package_cloud gems
RUN yum -y install gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison iconv-devel

# Install Go and other deps
RUN wget -q -O/tmp/go.tar.gz https://dl.google.com/go/go1.14.4.linux-amd64.tar.gz
RUN tar -xf /tmp/go.tar.gz -C /usr/local/
RUN rm -f /tmp/go.tar.gz

# Install nfpm
ENV PATH="${PATH}:/usr/local/go/bin"
RUN go get -u github.com/goreleaser/nfpm/cmd/nfpm
RUN rm -rf /root/go/src

# Add cairo
RUN yum -y install pixman-devel poppler-devel librsvg-devel libpng-devel tar xz libX11-devel libXext-devel
RUN mkdir ~/cairo
RUN cd ~/cairo && wget -q https://www.cairographics.org/releases/cairo-1.14.12.tar.xz && tar -xf cairo-1.14.12.tar.xz && cd  cairo-1.14.12 &&  ./configure --enable-shared="" --enable-static=cairo && make -j8 && make install
RUN sed -i 's/-lcairo/-lcairo -lm -lpng -lpixman-1 -lz -lX11 -lXext -lrt/' /usr/local/lib/pkgconfig/cairo.pc
RUN ln -sf /usr/local/lib/pkgconfig/* /usr/lib64/pkgconfig/

# Packing files
ADD pack.sh /root
ADD create_package_rpm.sh /root
ADD nfpm.yaml /root
RUN rm -f /root/*.rpm

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
