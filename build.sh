#!/bin/bash
#sudo docker build -t alexandrellemes/php-fpm-oci8:latest --squash --compress --force-rm -f Dockerfile .  && \
sudo docker build -t alexandrellemes/php-fpm-oci8:latest --compress --force-rm -f Dockerfile .  && \
[[ $1 == '--push' ]] && sudo docker push alexandrellemes/php-fpm-oci8:latest