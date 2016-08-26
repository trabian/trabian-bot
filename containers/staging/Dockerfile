FROM ubuntu:12.04

RUN apt-get -qq update

RUN apt-get install -y openssh-server sudo

RUN mkdir -p /var/run/sshd

RUN useradd -ms /bin/bash staging

COPY run /tmp/run
COPY add_env_hook /tmp/add_env_hook

RUN /bin/sh /tmp/add_env_hook

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

COPY ssh_key.pub /home/staging/.ssh/authorized_keys

CMD /bin/sh /tmp/run
