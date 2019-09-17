FROM php:fpm
#LABEL maintainer "Stefano Azzolini <stefano.azzolini@caffeina.com>"

#Variáveis de ambiente
ARG HOME
ARG URL_PROXY=http://10.6.156.114:3128
ARG DEBIAN_FRONTEND=noninteractive

ENV PASTA_TEMPORARIA /tmp

#
# Caso seja definido a configuração de PROXY.
#
ENV http_proxy ${URL_PROXY}
ENV ftp_proxy ${URL_PROXY}
ENV all_proxy ${URL_PROXY}
ENV https_proxy ${URL_PROXY}
ENV no_proxy localhost,127.0.0.1
ENV HTTP_PROXY ${URL_PROXY}
ENV FTP_PROXY ${URL_PROXY}
ENV ALL_PROXY ${URL_PROXY}
ENV HTTPS_PROXY ${URL_PROXY}

ENV PHP_VERSION ${PHP_VERSION}

ADD ./oracle/instantclient-basic-linux.x64-12.2.0.1.0.zip /tmp
ADD ./oracle/instantclient-sdk-linux.x64-12.2.0.1.0.zip /tmp
ADD ./oracle/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip /tmp

RUN apt-get update && apt-get -y install wget bsdtar libaio1 && \
 bsdtar -xvf /tmp/instantclient-basic-linux.x64-12.2.0.1.0.zip -C /usr/local && \
 bsdtar -xvf /tmp/instantclient-sdk-linux.x64-12.2.0.1.0.zip -C /usr/local && \
 bsdtar -xvf /tmp/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip -C /usr/local && \
 ln -s /usr/local/instantclient_12_2 /usr/local/instantclient && \
 ln -s /usr/local/instantclient/libclntsh.so.* /usr/local/instantclient/libclntsh.so && \
 ln -s /usr/local/instantclient/lib* /usr/lib && \
 ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus && \
 docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/local/instantclient && \
 docker-php-ext-install oci8 && \
 rm -rf /var/lib/apt/lists/* && \
 php -v

RUN wget http://php.net/distributions/php-7.1.6.tar.gz  --no-check-certificate && \
    mkdir php_oci && \
    mv php-7.1.6.tar.gz ./php_oci
WORKDIR php_oci
RUN tar xfvz php-7.1.6.tar.gz
WORKDIR php-7.1.6/ext/pdo_oci
RUN phpize && \
    ./configure --with-pdo-oci=instantclient,/usr/local/instantclient,12.1 && \
    make && \
    make install && \
    echo extension=pdo_oci.so > /usr/local/etc/php/conf.d/pdo_oci.ini && \
    php -v

VOLUME /etc/tnsnames.ora


