FROM oraclelinux:6.9

MAINTAINER Venood12 venood.khatuva12@gmail.com

# Basic packages
RUN yum update -y
RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm \
  && yum -y install passwd sudo git wget openssl openssh openssh-server openssh-clients jq

# Create user
RUN useradd sensu \
 && echo "sensu" | passwd sensu --stdin \
 && sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config \
 && sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config \
 && echo "sensu ALL=(ALL) ALL" >> /etc/sudoers.d/sensu

# Sensu server
ADD ./config-files/sensu.repo /etc/yum.repos.d/
RUN yum install -y sensu
ADD ./config-files/config.json /etc/sensu/conf.d/
ADD ./config-files/client.json /etc/sensu/conf.d/
ADD ./config-files/transport.json /etc/sensu/conf.d/
RUN mkdir -p /etc/sensu/ssl \
  && git clone git://github.com/joemiller/joemiller.me-intro-to-sensu.git \
  && cd joemiller.me-intro-to-sensu/; ./ssl_certs.sh clean && ./ssl_certs.sh generate \
  && cp /joemiller.me-intro-to-sensu/client_cert.pem /etc/sensu/ssl/cert.pem \
  && cp /joemiller.me-intro-to-sensu/client_key.pem /etc/sensu/ssl/key.pem

# uchiwa
RUN yum install -y uchiwa
ADD ./config-files/uchiwa.json /etc/sensu/

# supervisord
RUN yum install -y python-setuptools --skip-broken \
   && easy_install supervisor

ADD ./config-files/supervisord.conf /etc/supervisord.conf

EXPOSE 22 4567

CMD ["/usr/bin/supervisord"]
