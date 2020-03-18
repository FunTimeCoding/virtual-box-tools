FROM debian
MAINTAINER Alexander Reitzel
RUN apt-get --quiet 2 update
RUN apt-get --quiet 2 install openssh-server
RUN mkdir /run/sshd
RUN mkdir /root/.ssh
ADD tmp/id_rsa.pub /root/.ssh/authorized_keys
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
