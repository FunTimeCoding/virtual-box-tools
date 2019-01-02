FROM debian
MAINTAINER Alexander Reitzel
RUN apt-get --quiet 2 update
RUN apt-get --quiet 2 install lsb-release
ADD script/vagrant/provision.sh /root/provision.sh
RUN chmod +x /root/provision.sh
RUN /root/provision.sh
ADD . /virtual-box-tools
CMD ["/virtual-box-tools/bin/vbt"]
