FROM php:fpm
#LABEL maintainer "Stefano Azzolini <stefano.azzolini@caffeina.com>"

#Variáveis de ambiente
ARG HOME
ARG URL_PROXY
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

RUN pear config-set http_proxy http://${URL_PROXY}
RUN pecl channel-update pecl.php.net
RUN echo 'shared,instantclient,/usr/local/instantclient' | pecl install -f oci8

#PHP-7.3.9
#PHP-7.2.22
#PHP-7.1.32

RUN wget http://php.net/distributions/php-7.3.9.tar.gz  --no-check-certificate && \
    mkdir php_oci && \
    mv php-7.3.9.tar.gz ./php_oci
WORKDIR php_oci
RUN tar xfvz php-7.3.9.tar.gz
WORKDIR php-7.3.9/ext/pdo_oci
RUN phpize && \
    ./configure --with-pdo-oci=shared,instantclient,/usr/local/instantclient,12.1 && \
    make && \
    make install && \
    echo extension=pdo_oci.so > /usr/local/etc/php/conf.d/pdo_oci.ini && \
    php -v

VOLUME /etc/tnsnames.ora


