FROM debian:stretch-slim
MAINTAINER Katarina Golbang <golbang.k@gmail.com>

WORKDIR /tmp

RUN apt-get update
RUN apt-get install -y build-essential libpcre3 libpcre3-dev libexpat1-dev procps curl iputils-ping vim less
RUN curl -L http://www.openssl.org/source/openssl-1.0.1f.tar.gz --output openssl-1.0.1f.tar.gz
RUN tar -xvzf openssl-1.0.1f.tar.gz
RUN cd openssl-1.0.1f && ./config --prefix=/opt/openssl-1.0.1f --openssldir=/opt/openssl-1.0.1f && make && make install_sw

RUN curl -L http://mirror.klaus-uwe.me/apache//httpd/httpd-2.4.38.tar.gz --output httpd-2.4.38.tar.gz
RUN curl -L http://mirror.klaus-uwe.me/apache//apr/apr-1.6.5.tar.gz --output apr-1.6.5.tar.gz
RUN curl -L http://mirror.klaus-uwe.me/apache//apr/apr-util-1.6.1.tar.gz --output apr-util-1.6.1.tar.gz

RUN tar -xvzf httpd-2.4.38.tar.gz
RUN cd httpd-2.4.38/srclib/ && tar -xvzf ../../apr-1.6.5.tar.gz && ln -s apr-1.6.5/ apr \
 && tar -xvzf ../../apr-util-1.6.1.tar.gz && ln -s apr-util-1.6.1/ apr-util

RUN cd httpd-2.4.38 && ./configure --prefix=/opt/httpd \
 --with-included-apr \
 --enable-ssl \
 --with-ssl=/opt/openssl-1.0.1f \
 --enable-ssl-staticlib-deps \
 --enable-mods-static=ssl

RUN cd httpd-2.4.38 \
 && make \
 && make install

COPY server.crt /opt/httpd/conf/server.crt
COPY server.key /opt/httpd/conf/server.key
RUN sed -i \
         -e 's/^#\(Include .*httpd-ssl.conf\)/\1/' \
         -e 's/^#\(LoadModule .*mod_ssl.so\)/\1/' \
         -e 's/^#\(LoadModule .*mod_socache_shmcb.so\)/\1/' \
         /opt/httpd/conf/httpd.conf

CMD /opt/httpd/bin/apachectl -D FOREGROUND
EXPOSE 80

