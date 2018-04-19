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

RUN cd /opt/sensu/embedded/bin \
 && sensu-install -p cpu-checks  
 && sensu-install -p disk-checks \
 && sensu-install -p memory-checks \
 && sensu-install -p nginx \
 && sensu-install -p process-checks \  
 && sensu-install -p load-checks \  
 && sensu-install -p vmstats \  
 && sensu-install -p mailer 

# Sensu server
ADD ./config-files/sensu.repo /etc/yum.repos.d/
RUN yum install -y sensu
RUN mkdir -p /etc/sensu/conf.d/checks
ADD ./config-files/config.json /etc/sensu/
ADD ./config-files/client.json /etc/sensu/
ADD ./config-files/transport.json /etc/sensu/
ADD ./config-files/check_cpu.json /etc/sensu/conf.d/checks
ADD ./config-files/check_cpu_memory.json /etc/sensu/conf.d/checks
ADD ./config-files/check_disk.json /etc/sensu/conf.d/checks
ADD ./config-files/handler_mail.json /etc/sensu/handlers
ADD ./config-files/mailer.json /etc/sensu/handlers

RUN cd /opt/sensu/embedded/bin \
 && sensu-install -p cpu-checks
 && sensu-install -p disk-checks \
 && sensu-install -p memory-checks \
 && sensu-install -p nginx \
 && sensu-install -p process-checks \
 && sensu-install -p load-checks \
 && sensu-install -p vmstats \
 && sensu-install -p mailer

# Uchiwa
RUN yum install -y uchiwa
ADD ./config-files/uchiwa.json /etc/sensu/

# supervisord
RUN yum install -y python-setuptools --skip-broken \
   && easy_install supervisor

ADD ./config-files/supervisord.conf /etc/supervisord.conf

EXPOSE 4567

CMD ["/usr/bin/supervisord"]
