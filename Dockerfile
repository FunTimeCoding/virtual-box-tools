FROM debian
MAINTAINER Alexander Reitzel
ADD script/docker/provision.sh /root/provision.sh
RUN chmod +x /root/provision.sh
RUN /root/provision.sh
ADD . /virtual-box-tools
ENTRYPOINT ["/virtual-box-tools/bin/vbt"]
