#
# PHP Farm Docker image
#

FROM ubuntu:14.04

MAINTAINER @jhvaras

RUN apt-get update && \
    apt-get install -y \
    apache2 \
    apache2-mpm-prefork \
    git \
    build-essential \
    wget \
    libxml2-dev \
    libssl-dev \
    libsslcommon2-dev \
    libcurl4-openssl-dev \
    pkg-config \
    curl \
    libapache2-mod-fcgid \
    libbz2-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libxpm-dev \
    libmcrypt-dev \
    libt1-dev \
    libltdl-dev \
    libmhash-dev

# install and run the phpfarm script
RUN git clone git://git.code.sf.net/p/phpfarm/code phpfarm

# add customized configuration
COPY phpfarm /phpfarm/src/

# compile, then delete sources (saves space)
RUN cd /phpfarm/src && \
#    ./compile.sh 5.2.17 && \
#    ./compile.sh 5.3.29 && \
#    ./compile.sh 5.4.32 && \
#    ./compile.sh 5.5.16 && \
    ./compile.sh 5.6.1 && \
    rm -rf /phpfarm/src && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#RUN rm -rf /var/www/*

COPY var-www /var/www/
COPY apache  /etc/apache2/

RUN a2ensite php-5.6
#RUN a2ensite php-5.2 php-5.3 php-5.4 php-5.5 php-5.6
RUN a2enmod rewrite

ENV PATH /phpfarm/inst/bin/:/usr/sbin:/usr/bin:/sbin:/bin

EXPOSE 8052 8053 8054 8055 8056

RUN apache2ctl start

# attach shared folder
VOLUME ["/var/www/vhosts"]
#WORKDIR /var/www/vhosts

# Cmd not pollutiing Entrypoint
# Note: If CMD is used to provide default arguments for the ENTRYPOINT instruction, both the CMD and ENTRYPOINT instructions should be specified with the JSON array format.
# http://docs.docker.com/reference/commandline/cli/
ENTRYPOINT /bin/bash
CMD tail -f /var/log/apache2/error.log
