FROM centos:6
MAINTAINER Vladimir Smirnov <civil.over@gmail.com>

# Make sure the package repository is up to date.
RUN yum upgrade -y

RUN yum -y groupinstall "Development Tools"
RUN yum -y install tar which git openssh mercurial wget redhat-lsb-core openssh-server
RUN yum -y install centos-release-SCL

# Install Ruby and package_cloud gems
RUN yum -y install gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison iconv-devel
RUN curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -; curl -L get.rvm.io | bash -s stable
RUN export PATH="${PATH}:/usr/local/rvm/bin/"; source /etc/profile.d/rvm.sh; rvm install 2.0.0; rvm use 2.0.0 --default
RUN export PATH="${PATH}:/usr/local/rvm/rubies/ruby-2.0.0-p648/bin/"; gem install fpm; gem install package_cloud
RUN echo 'PATH="${PATH}:/usr/local/rvm/rubies/ruby-2.0.0-p648/bin/"' >> /etc/environment
#RUN yum --enablerepo=centos-sclo-rh -y install ruby193 ruby193-ruby-devel
#RUN cp /opt/rh/ruby193//enable /etc/profile.d/ruby.sh && chmod +x /etc/profile.d/ruby.sh

# Install Go and other deps
RUN wget -q -O/tmp/go.tar.gz https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz
RUN tar -xf /tmp/go.tar.gz -C /usr/local/
RUN rm -f /tmp/go.tar.gz

# Build static cairo
RUN yum -y install pixman-devel poppler-devel librsvg-devel libpng-devel tar xz libX11-devel libXext-devel
RUN mkdir ~/cairo
RUN cd ~/cairo && wget -q https://www.cairographics.org/releases/cairo-1.14.12.tar.xz && tar -xf cairo-1.14.12.tar.xz && cd  cairo-1.14.12 &&  ./configure --enable-shared="" --enable-static=cairo && make -j8 && make install
RUN sed -i 's/-lcairo/-lcairo -lm -lpng -lpixman-1 -lz -lX11 -lXext -lrt/' /usr/local/lib/pkgconfig/cairo.pc
RUN ln -sf /usr/local/lib/pkgconfig/* /usr/lib64/pkgconfig/

# Packagecloud
ADD pack.sh /root/
# Bintray
#ADD pack_bintray.sh /home/jenkins/

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
